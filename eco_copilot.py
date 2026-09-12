import os
import sys
import argparse
import pandas as pd
from tabulate import tabulate

from src.parser.sta_parser import OpenSTAParser
from src.features.feature_extractor import FeatureExtractor
from src.fingerprint.fingerprinter import ViolationFingerprinter
from src.rootcause.rootcause_engine import RootCauseEngine
from src.recommendation.eco_candidates import ECOCandidateGenerator
from src.recommendation.report_generator import RecommendationReportGenerator
from src.scoring.eco_scorer import ECOScorer
from src.tcl.tcl_generator import TclECOGenerator
from src.validation.eco_executor import ECOExecutor
from src.validation.validator import SignoffValidator

def banner():
    print("""
================================================================================
   ECO COPILOT -- Explainable Fix Recommendation & Closed-Loop Validation
   Target: OpenROAD / OpenSTA Signoff Flow (Nangate45 PDK)
================================================================================
""")

def run_pipeline(report_file="data/raw/baseline_sta.rpt", top_k=10, execute_eco=False, validate_eco=False):
    banner()

    if not os.path.exists(report_file):
        print(f"[-] Error: Report file '{report_file}' not found.")
        sys.exit(1)

    print(f"[*] Step 1: Parsing OpenSTA Signoff Report: {report_file}")
    parser = OpenSTAParser(report_file)
    paths = parser.parse()
    violating = [p for p in paths if p.is_violating]
    print(f"    -> Parsed {len(paths)} total paths ({len(violating)} violating setup constraints)")

    print("\n[*] Step 2: Extracting Path & Bottleneck Stage Features...")
    extractor = FeatureExtractor(paths)
    df_paths = extractor.extract_path_summary_features()
    df_stages = extractor.extract_stage_bottleneck_features()
    os.makedirs("data/processed", exist_ok=True)
    df_paths.to_csv("data/processed/path_features.csv", index=False)
    df_stages.to_csv("data/processed/stage_features.csv", index=False)

    print("\n[*] Step 3: Fingerprinting Violations & Diagnosing Root Causes...")
    fingerprinter = ViolationFingerprinter(df_paths, df_stages)
    df_fp = fingerprinter.fingerprint_all_paths()
    viol_fp = df_fp[df_fp["is_violating"] == True]

    engine = RootCauseEngine()
    eco_gen = ECOCandidateGenerator(df_stages)
    scorer = ECOScorer(lambda_risk=0.5)
    reporter = RecommendationReportGenerator()

    # Collect distinct critical cells across all violating paths for balanced ECO execution
    selected_batch_ecos = []
    seen_targets = set()

    print(f"\n[*] Step 4: Generating Explainable Recommendations for Top {top_k} Violations:")
    for idx in range(min(top_k, len(viol_fp))):
        path_row = viol_fp.iloc[idx]
        path_id = int(path_row["path_id"])

        fp_dict = {
            "cell_delay_dominance": path_row["cell_delay_dominance"],
            "slew_severity": path_row["slew_severity"],
            "fanout_load": path_row["fanout_load"],
            "drive_weakness": path_row["drive_weakness"],
            "depth_severity": path_row["depth_severity"]
        }

        diagnosis = engine.diagnose(path_row["violation_type"], fp_dict)
        candidates = eco_gen.generate_candidates_for_path(
            path_id, path_row["violation_type"], fp_dict, path_row.to_dict()
        )
        ranked = scorer.rank_candidates(candidates, path_row.to_dict())

        if idx == 0:
            print(reporter.generate_path_report(path_row.to_dict(), diagnosis, ranked))

        # Add top non-duplicate candidates to batch
        for c in ranked:
            t_cell = c.get("target_cell")
            if t_cell and t_cell not in seen_targets:
                selected_batch_ecos.append(c)
                seen_targets.add(t_cell)
                if len(selected_batch_ecos) >= 8:
                    break

    # Step 5: Tcl Generation
    print("\n[*] Step 5: Generating Executable OpenROAD Tcl Script...")
    tcl_gen = TclECOGenerator()
    tcl_file = tcl_gen.generate_eco_script(selected_batch_ecos, "scripts/apply_eco.tcl")
    print(f"    -> Generated: {tcl_file} ({len(selected_batch_ecos)} unique cell transformations)")

    print("\n" + "=" * 80)
    print("  SUMMARY OF PLANNED ECO ACTIONS:")
    print("=" * 80)
    summary_rows = []
    for i, eco in enumerate(selected_batch_ecos):
        summary_rows.append([
            i + 1,
            eco.get("eco_type"),
            eco.get("target_cell"),
            f"{eco.get('current_type')} -> {eco.get('target_type')}",
            f"~{eco.get('benefit_ns', 0):.3f} ns",
            f"{eco.get('net_score', 0):.2f}"
        ])
    headers = ["#", "ECO Action", "Target Cell", "Transformation", "Est. Saving", "Score"]
    print(tabulate(summary_rows, headers=headers, tablefmt="fancy_grid"))

    # Step 6: Closed-Loop Execution (if requested)
    if execute_eco:
        print("\n[*] Step 6: Executing ECO in OpenROAD (Detailed Placement + Re-Route + STA)...")
        executor = ECOExecutor("scripts/apply_eco.tcl")
        success = executor.run()
        if not success:
            print("[-] ECO Execution encountered an error.")
            return

    # Step 7: Post-ECO Validation Dashboard (if requested)
    if validate_eco or execute_eco:
        print("\n[*] Step 7: Running Signoff Before-vs-After Validation...")
        validator = SignoffValidator()
        results = validator.validate()
        validator.print_validation_report(results)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ECO Copilot Closed-Loop CLI")
    parser.add_argument("--report", default="data/raw/baseline_sta.rpt", help="Path to OpenSTA report")
    parser.add_argument("--top_k", type=int, default=10, help="Number of worst paths to analyze")
    parser.add_argument("--execute", action="store_true", help="Execute generated ECO Tcl script in OpenROAD")
    parser.add_argument("--validate", action="store_true", help="Run before-vs-after validation comparison")
    parser.add_argument("--all", action="store_true", help="Run full pipeline: analyze, generate, execute, validate")
    args = parser.parse_args()

    exec_flag = args.execute or args.all
    val_flag = args.validate or args.all
    run_pipeline(report_file=args.report, top_k=args.top_k, execute_eco=exec_flag, validate_eco=val_flag)
