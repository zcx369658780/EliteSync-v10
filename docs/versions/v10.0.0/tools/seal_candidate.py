"""Seal finite technical identities and verify preservation, without modifying the original root."""
import hashlib,json,pathlib,subprocess,re
root=pathlib.Path(__file__).resolve().parents[4]; src=pathlib.Path(r"D:\EliteSync-v10"); ev=root/"docs/versions/v10.0.0/evidence"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def git(r,*args):return subprocess.check_output(["git","--no-optional-locks","-C",str(r),*args],text=True,stderr=subprocess.PIPE).strip()
before=json.loads((ev/"root-before.json").read_text()); status=git(src,"status","--porcelain=v1","--untracked-files=normal")
registry=git(src,"worktree","list","--porcelain")
blocks=registry.split("\n\n"); normalized=[]
for block in blocks:
    lines=block.splitlines()
    if lines and pathlib.Path(lines[0].removeprefix("worktree ")).resolve()==root:
        lines=[("HEAD "+before["head"]) if x.startswith("HEAD ") else x for x in lines]
    normalized.append("\n".join(lines))
registry_original_candidate_head="\n\n".join(normalized)
index=pathlib.Path(git(src,"rev-parse","--path-format=absolute","--git-path","index"))
after={"head":git(src,"rev-parse","HEAD"),"branch":git(src,"branch","--show-current"),"index_sha256":sha(index),"status_sha256":hashlib.sha256(status.encode()).hexdigest(),"tracked_changed":len(git(src,"diff","--name-only").splitlines()),"untracked_normal":sum(x.startswith("??") for x in status.splitlines()),"old_worktree_registry_preserved":hashlib.sha256(registry_original_candidate_head.encode()).hexdigest()==before["existing_worktrees_sha256"],"worktree_count":len(blocks),"tracked_files_match":all(sha(src/x["path"])==x["sha256"] for x in before["tracked_files"]),"protected_files_match":all(sha(src/x["path"])==x["sha256"] for x in before["protected_files"])}
after["original_root_preserved"]=all(after[k]==before[k] for k in ("head","branch","index_sha256","status_sha256","tracked_changed","untracked_normal")) and all(after[k] for k in ("old_worktree_registry_preserved","tracked_files_match","protected_files_match"))
(ev/"root-after.json").write_text(json.dumps(after,indent=2)+"\n",encoding="utf-8"); assert after["original_root_preserved"],after
intake=json.loads((ev/"source-intake.json").read_text()); run=json.loads((ev/"run-002/receipt.json").read_text())
assert run["exit_code"]==0 and run["coverage_files_exact"] and run["inputs_unchanged"]
assert all(sha(root/x["path"])==x["sha256"] for x in run["inputs"])
config=json.loads((ev/"autoload-probe.json").read_text()); assert config["all_selected_classes_loaded_from_isolated_candidate"]
paths={x["path"] for x in intake["files"]}
paths.update(str(x.relative_to(root)).replace("\\","/") for x in ev.rglob("*") if x.is_file())
paths.update(["services/backend-laravel/phpunit.v100.xml","docs/versions/v10.0.0/plan.md","docs/versions/v10.0.0/.gitattributes","docs/versions/v10.0.0/execution.md","docs/workflow/CURRENT_WORKFLOW.md"])
paths.update(str(x.relative_to(root)).replace("\\","/") for x in (root/"docs/versions/v10.0.0/tools").glob("*.py"))
authority=["docs/architecture/ELITESYNC_V10_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_ACCEPTANCE_V0_1.md","docs/architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_ACCEPTANCE_V0_1.md","EVIDENCE/BE-05-MESSAGING-CONSENT-FAMILY-FAIL-CLOSED-REPAIR/work-review.md","EVIDENCE/BE-08-MESSAGING-CONSENT-AUDIENCE-BINDING-REPAIR/work-review.md"]
paths.update(authority)
files=[]
for path in sorted(paths):
    file=root/path
    assert file.is_file()
    files.append({"path":path,"bytes":file.stat().st_size,"runtime_bytes_sha256":sha(file),"canonical_git_blob":git(root,"hash-object","--",path),"purpose":"HISTORICAL_ACCEPTANCE" if path in authority else ("SELECTED_TEST_CLOSURE" if path in {x["path"] for x in intake["files"]} else "VERSION_EVIDENCE_OR_REPRODUCTION")})
manifest={"schema":"elitesync-v100-technical-manifest-v1","code_parent":"4bebc8f394248e254c1368a06fbdee5d2c883301","frozen_plan_commit":"8072ba51ad1dde2e3c3262a418af54531dcec7e0","frozen_plan_blob":"ae84a65e3636fa51a188c687154cb51856f58bf9","scope":["A","B","D"],"candidate_branch":"codex/v10-0-0-boundary-closure-20261013","final_commit_and_tree_binding":"The immutable Git commit/tree containing this manifest; reported in Owner delivery receipt. Manifest excludes its own recursive hash.","final_validation":"evidence/run-002/receipt.json","files":files,"original_root_preserved":True,"byte_identity_note":"runtime_bytes_sha256 records Windows test checkout bytes; canonical_git_blob is the Git identity after attributes/EOL normalization. evidence/** is -text to retain raw streams.","excluded":["vendor binaries","Flutter/local-only App/EliteSync","unrelated EVIDENCE","C bridge","V57/H1/H2/D0","real data and production"],"acceptance":"ASTRA_PENDING"}
assert git(root,"hash-object","--","docs/versions/v10.0.0/plan.md")==manifest["frozen_plan_blob"]
(root/"docs/versions/v10.0.0/manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
print(json.dumps({"technical_files":len(files),"selected_files":len(intake["files"]),"manifest_sha256":sha(root/"docs/versions/v10.0.0/manifest.json"),"root_preserved":after["original_root_preserved"],"protected_files":len(before["protected_files"]),"worktrees":after["worktree_count"]}))
