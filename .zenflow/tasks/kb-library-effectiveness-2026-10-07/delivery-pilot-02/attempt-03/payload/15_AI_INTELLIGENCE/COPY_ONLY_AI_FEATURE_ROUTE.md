# AI feature — copy-only reference route

Use for iOS model inference, AI-assisted UI, prompts, retrieval, tool calling or model-provider
integration. First apply local AI/task routing, privacy and product rules; this route is an
additional review, not a provider connection, external model call or authorization to send data.

1. Define the exact user task, supported devices/OS, model/provider and fallback behavior.
   Treat capability and model version as dependencies: verify current platform/API claims from
   official sources when they affect implementation, and label unsupported assumptions.
   Bound prompt, retrieved context and output/token budgets where truncation, cost, latency
   or missing evidence could alter correctness; do not assume a model saw omitted context.
   First check whether deterministic logic or a specialized framework solves the user need.
   Version prompt/schema/model and pre/post-processing together where their contracts interact;
   inspect package provenance, compatibility, update/rollback and storage/resource bounds.
2. Trace every data boundary: user content, sensitive inputs, on-device versus network path,
   retention/logging, permissions and error exposure. Tool calls and side effects need explicit
   authorization, validated arguments, idempotency or duplicate-action handling, and failure
   containment. Generated output is untrusted data until checked at its consumer boundary.
   Structured output is not authorization: validate selected IDs/values and confirm sensitive
   irreversible actions at the app boundary. Inspect system/user/retrieved/tool instruction
   separation, exfiltration/rate limits, deterministic redaction and justified retention/deletion.
   For retrieval, trace index/freshness/permissions and source-chunk provenance; a generated
   citation must actually support its claim, and missing evidence must allow abstention.
3. Evaluate useful quality dimensions on representative and negative cases: correctness,
   unsafe output, prompt injection where external content is read, latency/resource envelope,
   accessibility, cancellation, unavailable model and graceful fallback. A sample prompt or
   passing demo does not prove general quality.
   Use a defined rubric/dataset with ambiguous, conflicting/outdated, malformed/long, locale,
   sensitive and adversarial cases as relevant; compare versions on the same evidence rather
   than optimizing a few examples. Separate schema validity from semantic quality and safety.
   For streaming, inspect partial-state meaning, segment identity/order, reconnect/duplicates,
   cancellation and accessible error recovery; partial output is not a completed action.
   For Vision/OCR/ML, inspect orientation/ROI/pixel/color/language preprocessing, request/model
   revision, confidence/tolerance, batching/scheduling and device/model variance. Distinguish
   model quality from preprocessing or session bugs; a fixed fixture alone is not general quality.
4. Recommend the smallest evidence plan and report observed evaluations separately from
   proposed ones. For changed code/resources, inspect all affected consumers and the final
   complete diff; no production or privacy claim without corresponding evidence.

`AUTO` performs only in-scope reasoning and read-only inspection after the local layer;
`ADVISORY` prioritizes evals and permission-dependent actions. Both respect separate authority
for network, model calls, agents, builds/tests and data sharing. This distills useful checks
from the former `ioslib-ai-ml` and AI feature review sources, not their installed runtime.
