# Herd Workflow

## Parsing

Key data structures:
test_herd.mli and [archExtra_herd.ml](archExtra_herd.ml:83): internal representation of the litmus program:
XXXParser.mly: architecture grammar & token-to-object translation 

menhir-parsers transform litmus test into the internal representations [test_herd](test_herd.mli:20) and cat-model [model](model.mli:23)
1. [select](parseTest.ml:88) architecture ([Archs.parse](../lib/Archs.ml:48)) from the test's architecture string
2. [select](parseTest.ml:168) the architecture's litmus parser
3. [parses](runTest.ml:65) the program (it becomes a [map](archExtra_herd.ml:83) addr/label -> instruction-list)

Examples:
[LDR](../lib/AArch64Parser.mly:700)
[CBZ](../lib/AArch64Parser.mly:693)


## Construct Candidate Event Structures

Structs/modules:
runTest.ml and top_herd.ml: dispatch and oversight to run a test
monad.mli and eventsMonad.ml: providing binders for the construction of potential event structures.
XXXSem.ml: uses the binders to translate every instruction into event structures with iico-edges.
[eventStructure](event.ml:215): event structures. holds instruction internal iico-edges & beyond-instruction po-edges. Every event has an action with a return type

[glommed_event_structures](mem.ml:342) generates potential control-flow-fixed event structures, collecting thread-local constraints for register values.
It generates only iico-edges and po-indices (effectively po-edges). No rf/co edges yet.
1. [translates](AArch64Sem.ml:4120) instructions into constraint lists & event structures according to its semantics
2. [stitches](mem.ml:652) them together with the [code monad](eventsMonad.ml:1125) (generating po-indices)

Examples:
[LDR](AArch64Sem.ml:4221)
[CBZ](AArch64Sem.ml:4195)

## Generate Concrete Event Structures

Structs/modules:
runTest.ml and top_herd.ml: dispatch and oversight to run a test
[rfmap](semExtra.ml:134): keeps track of which event obtained its value from which other event (both for registers/memory)
[concrete](semExtra.ml:170): event structure + rfmap + final writes (inside rfmap)

[exec_iter](top_herd.ml:493) takes a potential event structure and iterates over concrete instantiations of it with [iter_rfms](top_herd.ml:310) to fix readfrom relations.
1. [solve](mem.ml:1092) its thread-local constraints. discard the potential event structure if not possible.
2. [enumerate](mem.ml:1379) memory rf relations and their constraints (equality of written and read value).
3. [solve](mem.ml:1416) each rf relation's constraints. discard a rf relation if not possible.
4. [partially sets co](mem.ml:2244): (final) writes per location and initial writes come first.

## Check Concrete Event Structures

Structs/modules:
model.mli: internal representation of the cat-model
AST.mli: Internal representation of parsed CAT-Syntax
[st](../lib/interpreter.ml:574) state of cat interpreter, containing [env](../lib/interpreter.ml:324), the map from var-names to their [values](../lib/interpreter.ml:309) (relations)
[Count.t](top_herd.ml:268) collects the results

an interpreter executing the CAT-model line-by-line on the concrete event structure [call_model](top_herd.ml:496) to identify whether the concrete event structure is possible
1. [enumerate](libdir/cross.cat) possible co orders and fork further evaluation for each
2. [initialise](../lib/interpreter.ml:2738) env with base relations (po, rf, co, iico-data, iico-ctrl)
3. [execute](../lib/interpreter.ml:1262) each line of the model
4. [collects](top_herd.ml:496) the concrete event structures, whether rejected or allowed and whether they satisfy postcondition or not.

Examples:
[dependency-ordered-before](./libdir/aarch64hwreqs.cat:93)
[dtrm](./libdir/aarch64deps.cat:61)
[aarch64 constraints](./libdir/aarch64.cat:160)

## Print Results

Structs/modules
[stats](top_herd.mli:35): collected stats during the run

[outputs](top_herd.ml:164) the stats collected
* Allowed (exists-query) / Forbidden (~exists) / Required (forall)
* States: the final states reached by allowed event structures (restricted to variables in constraint)
* Ok / No: whether postcondition is true or false
* Positive / Negative: count of event structures with true / false postcondition

## Ideas

* Feature: symbolic initial values for non-addresses.
* Reorder cat file/evaluation: co enumeration and forking only non-co-dependent assignments, so that forking the execution does not recompute the same relations multiple times.
    (did a claude-code moon-shot, not faster on the tests of the repo, only faster when many co-orders exist)
* Merge cli.ml/runTest.ml/top_herd.ml into a single control-flow driver that oversees the 4 phases
* Deduplicate Data from modules: Keep things in one place. (i.e., Sem/Arch is only in one struct - use local renames rather than Make()-functors) - rely on invariants rather than types to ensure correctness

## Questions Answered

1. How is the litmus test parsed and represented internally? test_herd.mli, archExtra_herd.ml
2. What are the key intermediate data structures? the structs/modules listed in each phase
3. How are candidate executions generated? phase 2
4. How are relations such as po, rf, co, etc., constructed? po: phase 2, rf: phase 3, co: depends: phase 3 or 4, derived: phase 4
5. How is the memory model applied to filter or validate executions? phase 4
6. How is the final result (Allowed/Forbidden, witnesses, etc.) determined and printed? Check: postcondition holds. how are witnesses processed.

## Did not look at:

* Solver encoding / calling.
