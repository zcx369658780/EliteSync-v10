"""Pure v1 contract checks; never authorizes build or artifact execution."""
import argparse
import json
from pathlib import Path

VALID_NOT_READY = "CONTRACT_VALID_RUNTIME_NOT_READY"


class ContractError(ValueError):
    """Malformed or inadmissible source-only contract."""


# The complete v1 allowlist: values are fixed, not runtime-discovered.
_EXPECTED = json.loads("{\"schemaVersion\":1,\"applicationId\":\"com.elitesync.syntheticdemo\",\"namespace\":\"com.elitesync.syntheticdemo\",\"mode\":\"debug\",\"syntheticDemo\":true,\"target\":\"lib/main.dart\",\"dartDefines\":[\"ELITESYNC_SYNTHETIC_DEMO=true\"],\"tools\":{\"flutter\":\"D:\\\\flutter\",\"androidSdk\":\"C:\\\\Users\\\\zcxve\\\\AppData\\\\Local\\\\Android\\\\Sdk\",\"jdk\":\"C:\\\\Program Files\\\\Eclipse Adoptium\\\\jdk-17.0.18.8-hotspot\",\"gradle\":\"C:\\\\Users\\\\zcxve\\\\.gradle\\\\wrapper\\\\dists\\\\gradle-8.14-all\\\\5vwl8burbouivoo2kromnbp2p\\\\gradle-8.14\"},\"staging\":{\"host\":\"host\",\"module\":\"module\",\"gradleUserHome\":\"gradle-user-home\",\"gradleProjectCache\":\"gradle-project-cache\",\"pubCache\":\"pub-cache\",\"userHome\":\"user-home\",\"temp\":\"temp\",\"repo\":\"repo\",\"receipts\":\"receipts\"},\"artifact\":{\"status\":\"NOT_READY\"},\"gates\":{\"sourceClosure\":\"UNRESOLVED\",\"sdkGeneration\":\"UNRESOLVED\",\"autoConfigurationIsolation\":\"UNRESOLVED\",\"dependencyMaterials\":\"UNRESOLVED\",\"aarIdentity\":\"UNRESOLVED\",\"mergedManifest\":\"UNRESOLVED\",\"pluginSideEffects\":\"UNRESOLVED\",\"appDataIsolation\":\"UNRESOLVED\"},\"receiptRequirements\":{\"status\":\"UNRESOLVED\",\"requiredFields\":[\"inputManifestSha256\",\"toolIdentities\",\"target\",\"mode\",\"dartDefines\",\"hostSynthetic\",\"aarSha256\",\"originalGav\",\"isolatedGav\",\"pomSha256\",\"dependencyClosure\",\"isolationEvidence\",\"mergedManifestSha256\"],\"verification\":\"FUTURE_INDEPENDENT_GATE_REQUIRED\"}}")


def _object_no_duplicates(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ContractError("Duplicate JSON key: " + key)
        result[key] = value
    return result


def _reject_constant(value):
    raise ContractError("Non-finite JSON constant: " + value)


def parse_contract(text):
    try:
        return json.loads(
            text,
            object_pairs_hook=_object_no_duplicates,
            parse_constant=_reject_constant,
        )
    except json.JSONDecodeError as error:
        raise ContractError("Invalid JSON syntax") from error


def _check_exact(actual, expected, field):
    if type(actual) is not type(expected):
        raise ContractError(field + ": exact type required")
    if type(expected) is dict:
        if actual.keys() != expected.keys():
            raise ContractError(field + ": missing or unknown fields")
        for key, value in expected.items():
            _check_exact(actual[key], value, field + "." + key)
    elif type(expected) is list:
        if len(actual) != len(expected):
            raise ContractError(field + ": wrong length or duplicate/conflicting values")
        for index, value in enumerate(expected):
            _check_exact(actual[index], value, field + "[" + str(index) + "]")
    elif actual != expected:
        # Fixed staging names reject traversal, absolute/UNC/drive paths
        # without resolving, reading or stat-ing any external path.
        raise ContractError(field + ": fixed v1 value required")


def validate_contract(contract):
    """Return only structural validity with runtime explicitly not ready."""
    _check_exact(contract, _EXPECTED, "contract")
    return VALID_NOT_READY


def admit_runtime(contract):
    """v1 cannot authorize any execution, even with a valid structure."""
    validate_contract(contract)
    raise ContractError("RUNTIME_NOT_READY: verified artifact and isolation gates unresolved")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("contract", help="Explicit contract file to read")
    parser.add_argument("--admit-runtime", action="store_true")
    args = parser.parse_args(argv)
    try:
        contract = parse_contract(Path(args.contract).read_text(encoding="utf-8"))
        if args.admit_runtime:
            admit_runtime(contract)
        print(validate_contract(contract))
    except (ContractError, OSError, UnicodeError) as error:
        parser.exit(2, str(error) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
