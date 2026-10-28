#!/bin/zsh
# Call a VM-service extension (ext.flutter.driver or custom ext.*) directly over
# the app's VM-service websocket. Bypasses dart_mcp_server finder-serialization bugs.
#
# Usage: vm-call.sh <ext.method> '<params json>'
#   vm-call.sh ext.flutter.driver '{"command":"tap","finderType":"ByValueKey","keyValueString":"menu-home","keyValueType":"String","timeout":"8000"}'
#   vm-call.sh ext.myapp.tapAt '{"x":"500","y":"300"}'
#
# SET the app's VM-service websocket URI via:  export UNYO_VM_WS=ws://...
# (found in `flutter run` output — "A Dart VM Service on Linux is available at ..." —
# use the ws:// form, or in Dart MCP get_app_logs as app.debugPort -> wsUri).
# If UNYO_VM_WS is unset, falls back to the literal below (edit it per app).
WS="${UNYO_VM_WS:-ws://127.0.0.1:44503/-iojy6NZl20=/ws}"

ISOLATE=$(printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"getVM"}' | websocat -n1 "$WS" | python3 -c "import json,sys; print(json.load(sys.stdin)['result']['isolates'][0]['id'])")
PARAMS=$(python3 -c "import json,sys; a=json.loads(sys.argv[1]); a['isolateId']='$ISOLATE'; print(json.dumps(a))" "$2")
printf '%s\n' "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"$1\",\"params\":$PARAMS}" | websocat -n1 "$WS"
echo
