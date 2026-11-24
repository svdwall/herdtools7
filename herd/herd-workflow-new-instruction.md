# Implementing LLDAR/CLLDAR

## Parsing
1. Introduce the instruction in AArch64Base.ml ([LLDAR](./lib/AArch64Base.ml:1446) reuses the LDAR struct, [CLLDAR](./lib/AArch64Base.ml:1446))
2. Create them in menhir grammar ([LLDAR](./lib/AArch64Parser.mly:748), [CLLDAR](./lib/AArch64Parser.mly:750))

## Instruction semantics
1. Encode instruction semantics using the monad binders ([CLLDAR](./AArch64Sem.ml:4241))
2. Write integration test ([LDDAR](./tests/instrunctions/A266), [CLDDAR](./tests/instrunctions/A267))

## Cat semantics
1. Introduce a new cat annotation: LA (limited acquire) ([LA](AArch64Annot.ml:19))
2. Introduce limited-acquire edges to the CAT model ([bob](./libdir/aarch64hwreqs.cat:139))

## Write Litmus tests to check intended behaviour
1. LLDAR
    * test for ordering ([MP+rel+LLDAR.litmus](../catalogue/aarch64/tests/MP+rel+LLDAR.litmus))
    * test for non-ordering with later memory instruction ([MP+rel+LLDAR.litmus](../catalogue/aarch64/tests/MP+rel+LLDAR-fail.litmus))
2. CLLDAR
    * test for ordering ([MP+rel+CLLDAR.litmus](../catalogue/aarch64/tests/MP+rel+CLLDAR.litmus))
    * test for non-ordering with later memory instruction ([MP+rel+LLDAR.litmus](../catalogue/aarch64/tests/MP+rel+CLLDAR-fail.litmus))

