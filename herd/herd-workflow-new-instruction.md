# Implementing LLDAR/CLLDAR

## Create instruction and update parser/lexer
1. Introduce the instruction in AArch64Base.ml ([LLDAR](./lib/AArch64Base.ml:1446) reuses the LDAR struct, [CLLDAR](./lib/AArch64Base.ml:1446))
2. Introduce a new annotation: LA (limited acquire) ([LA](AArch64Annot.ml:19))

## Instruction semantics and CAT semantics
3. Encode instruction semantics using the monad binders ([CLLDAR](./AArch64Sem.ml:4241))
4. Introduce limited-acquire edges to the CAT model ([bob](./libdir/aarch64hwreqs.cat:139))
5. Write integration test ([LDDAR](./tests/instrunctions/A266), [CLDDAR](./tests/instrunctions/A267))

## Write Litmus tests to check intended behaviour
6. LLDAR
    * test for ordering ([MP+rel+LLDAR.litmus](../catalogue/aarch64/tests/MP+rel+LLDAR.litmus))
    * test for non-ordering with later memory instruction ([MP+rel+LLDAR.litmus](../catalogue/aarch64/tests/MP+rel+LLDAR-fail.litmus))
7. CLLDAR
    * test for ordering ([MP+rel+CLLDAR.litmus](../catalogue/aarch64/tests/MP+rel+CLLDAR.litmus))
    * test for non-ordering with later memory instruction ([MP+rel+LLDAR.litmus](../catalogue/aarch64/tests/MP+rel+CLLDAR-fail.litmus))

