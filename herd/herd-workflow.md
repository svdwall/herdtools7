# Herd Workflow

## Parsing

Structs/modules:
test_herd.mli: internal representation of the litmus program
model.mli: internal representation of the cat-model
XXXParser.mly: architecture grammar & token-to-object translation 

menhir-parsers transform litmus test into the internal representations [test_herd](test_herd.mli:20) and cat-model [model](model.mli:23)
1. [parseTest](parseTest.ml:88) selects architecture ([Archs.parse](../lib/Archs.ml:48)) and cat model, and
2. [selects](parseTest.ml:168) the architecture's litmus parser to construct [runTest](runTest.ml:65) 

Examples:
[LDR](../lib/AArch64Parser.mly:700)
[CBZ](../lib/AArch64Parser.mly:693)


## Construct Candidate Event Structures

Structs/modules:
runTest.ml and top_herd.ml: dispatch and oversight to run a test
monad.mli and eventsMonad.ml: providing binders for the construction of potential event structures.
XXXSem.ml: uses the binders to translate every instruction into event structures with iico-edges.

[glommed_event_structures](mem.ml:342) generates potential control-flow-fixed event structures, collecting thread-local constraints for register values.
It generates only iico-edges and po-edges. No rf/co edges yet.
1. Translates instructions into constraint lists & event structures using their translation in [AArch64Sem](AArch64Sem.ml:4120) (generating iico-edges)
2. then stitches them together with the [code monad](eventsMonad.ml:1125) (generating po-edges)

Examples:
[LDR](AArch64Sem.ml:4221)
[CBZ](AArch64Sem.ml:4195)

## Generate Concrete Event Structures

Structs/modules:
runTest.ml and top_herd.ml: dispatch and oversight to run a test
[rfmap](semExtra.ml:134): keeps track of which event obtained its value from which other event (both for registers/memory)
[concrete](semExtra.ml:170): event structure + rfmap + final writes (inside rfmap)

[exec_iter](top_herd.ml:493) takes a potential event structures and iterates over concrete instantiations of it with [iter_rfms](top_herd.ml:310) to fix readfrom relations.
1. solve its thread-local constraints [do_solve_regs](mem.ml:1092). discard the potential event structure if not possible.
2. enumerate memory rf relations [solve_mem_or_res](mem.ml:1379) and their constraints (equality of written and read value).
3. solve each rf relation's constraints [still solve_mem_or_res](mem.ml:1416). discard an rf if not possible.
4. choose co-maximal (final) writes per location [fold_mem_finals](mem.ml:2244) and build the concrete event structures.


## Check Concrete Event Structures

Structs/modules:
AST.mli: Internal representation of parsed CAT-Syntax
[v](../lib/interpreter.ml:275) values that cat expressions can take
[env](../lib/interpreter.ml:290) maps cat-variables to their values

an interpreter executing the CAT-model line-by-line on the concrete event structure [call_model](top_herd.ml:496) to identify whether the concrete event structure is possible
1. set base relations in the initial environment 
2. execute each line of the model with [interpret](../lib/interpreter.ml:1262) until either a Test tails or the model has fully executed.
3. collects the executable concrete event structures

Examples:
[dependency-ordered-before](./libdir/aarch64hwreqs.cat:93)
[dtrm](./libdir/aarch64deps.cat:61)
[aarch64 constraints](./libdir/aarch64.cat:160)

## Ideas
* Merge cli.ml/runTest.ml/top_herd.ml into a single control-flow driver that oversees the 4 phases
* Deduplicate Data from modules: Keep things in one place. (i.e., Sem/Arch is only in one struct - use local renames rather than Make()-functors) - rely on invariants rather than types to ensure correctness
* Feature: symbolic initial values for non-addresses.
