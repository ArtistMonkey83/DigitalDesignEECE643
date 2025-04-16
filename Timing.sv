// Timing:
// One of the most challenging issues in circuit design is timing: making a circuit run fast.
// An output takes time to change in response to an input change.
// The transition from LOW to HIGH is called the rising edge. The transition from HIGH to LOW is called the falling edge.
// We measure delay from the 50% point of the input signal, A, to the 50% point of the output signal, Y.
// The 50% point is the point at which the signal is halfway (50%) between its LOW and HIGH values as it transitions.

// Propagation and Contamination Delay of a Combinational Logic
// Combinational logic is characterized by its propagation delay and contamination delay.
// Propagation Delay (t_pd): The propagation delay t_pd is the maximum time from when any input changes until the output or outputs reach their final value.
// Contamination Delay(t_cd): The contamination delay t_cd is the minimum time from when any input changes until any output starts to change its value.

//    A ─▶ Y
//    ┌────────────────────────────────────────────
//    │
// A  │    ┌────------------------────┐
//    │    │                          │
//    │────┘                          └───────────────────
//    │
//    │             ────────────
//    │            /             \
//    │           /               \
// Y  │          /                 \
//    │         /                   \
//    │───────/                     \─────────────
//    │
//    │     <---- t_pd ------------->
//    │
//    │     <-t_cd-->
//    │
//    │   ─────────────────────────────────────────
//    │                     Time
//    │
//    └────────────────────────────────────────────
// Y definitely settles to its new value within t_pd.
// A is initially either HIGH or LOW and changes to the other state at a particular time.

// Propagation and Contamination Delay
// Note: 
// When designers speak of calculating the delay of a circuit, they generally are referring to the worst-case value (the propagation delay).

// The underlying causes of delay in circuits include the time required to charge the capacitance in a circuit and the speed of light.
// Circuit delays are ordinarily on the order of picoseconds (1 ps = 10−12 seconds) to nanoseconds (1 ns = 10−9 seconds).


// tpd and tcd may be different for many reasons, including:
// Different rising and falling delays
// Multiple inputs and outputs, some of which are faster than others
// Circuits slowing down when hot and speeding up when cold


// Calculating t_pd and t_cd
// Propagation and contamination delays are determined by the path a signal takes from input to output.

//           "Critical Path"                                         
// ──────────────────────────────────|
//                                   |           
//        ┌───┐   n1    ┌───┐   n2   | 
// A ─────┤AND├─────────┤OR ├─────────------─|
//        └───┘         └─┬─┘                |
//         |             |                   |  ┌──-─┐
//         |             |                   ──-─ AND   ---- Y
// B ─────-|             |                   |  └──-─┘
//                       |                   |
//                       |                   |
// C ─────----───────────┤                   |
//                                           |
// D ----------------------------------------│           
//                                   │           
//                                   │           
//           "Short Path" ───────────┘           
   

// The critical path is the longest—and, therefore, the slowest—path because the input travels through three gates to the output.
// This path is critical because it limits the speed at which the circuit operates.
// The short path is the shortest—and, therefore, the fastest—path through the circuit because the input travels through only a single gate to the output.





// Critical Path:
//   A
//   ┌──────────────
//   │    ┌──┐
//   │    │  │       ┌──┐
//   │    │  │       │  │
// n1│────┘  └───────┘  └────
//   │
//   │              ┌──┐
//   │              │  │
// n2│──────────────┘  └─────
//   │
//   │                       ┌----
//   │                       │
//  Y│───────────────────────┘
//   │
//   │ <------ delay ---------->
//   │
//   Time
//   └──────────────────────>

// Shortest Path:
//   D
//   ┌──────────────────────
//   │    ┌─----─┐
//   │    │      │              ┌
//   │────┘      └──────────────┘
//   │
//   │
//   │
//  Y│──────────────────────
//   │
//   │ <--delay-->
//   │
//   Time
//   └──────────────────────>

// The propagation delay of a combinational circuit is the sum of the propagation delays through each element on the critical path.
// The contamination delay is the sum of the contamination delays through each element on the short path.

// t_pd = 2 * t_pd_AND + t_pd_OR

// t_cd = t_cd_AND
heeeeeeeerrrrrrrreeeee
// Although we are ignoring wire delay in this analysis, digital circuits are now so fast that the delay of long wires can be as important as the delay of the gates.



// Example: Find the propagation delay and contamination delay of the given circuit.
// Assume each gate has a propagation delay of 100 picoseconds (ps) and a contamination delay of 60 ps.
// Critical path is from input A or B through three gates to the output Y.
// t_pd = t_pd_AND + t_pd_NAND + t_pd_XOR = 300ps
// Shortest path is from input C, D, or E through two gates to the output Y.
// t_cd = t_cd_OR + t_cd_XOR = 120ps

// Mitigation of Glitches
// In most cases a single input transition causes a single output transition.
// However, it is possible that a single input transition can cause multiple output transitions.
// These are called glitches or hazards.
// Although glitches usually don’t cause problems, it is important to realize that they exist and recognize them when looking at timing diagrams.
// Example: A combinational circuit with a glitch.
// Y starts at 1 and ends at 1 but momentarily glitches to 0.
// To mitigate glitches, if the circuitry implementing one of the prime implicants turns off before the circuitry of the other prime implicant can turn on, there is a glitch.
// Fix: To fix this, we add another circle that covers that prime implicant boundary (consensus theorem or redundant term).

// Timing of Sequential Logic
// A flip-flop copies the input D to the output Q on the rising edge of the clock.
// This process is called sampling D on the clock edge.
// Question: If D is stable at either 0 or 1 when the clock rises, this behavior is clearly defined.
// But what happens if D is changing at the same time the clock rises?
// This problem is similar to that faced by a camera when snapping a picture.
// Imagine photographing a frog jumping from a lily pad into the lake.
// If you take the picture before the jump, you will see a frog on a lily pad.
// If you take the picture after the jump, you will see ripples in the water.
// But if you take it just as the frog jumps, you may see a blurred image of the frog stretching from the lily pad into the water.
// A camera is characterized by its aperture time, during which the object must remain still for a sharp image to be captured.
// Similarly, a sequential element has an aperture time around the clock edge, during which the input must be stable for the flip-flop to produce a well-defined output.
// The aperture of a sequential element is defined by a setup time and a hold time, before and after the clock edge, respectively.
// Dynamic Discipline: The dynamic discipline restricts us to utilizing signals that vary outside the setup and hold time.

// System Timing
// Clock period or cycle time: The clock period or cycle time, T_c, is the time between rising edges of a repetitive clock signal.
// Clock frequency: The reciprocal of clock period. Increasing the clock frequency increases the work that a digital system can accomplish per unit time.
// Frequency is measured in units of Hertz (Hz), or cycles per second: 1 megahertz (MHz) = 10^6 Hz, and 1 gigahertz (GHz) = 10^9 Hz.

// Setup and Hold Time Constraint
// For the setup time constraint, we need only the maximum delay through the path.
// To satisfy the setup time of R2, D2 must settle no later than the setup time before the next clock edge.
// We can calculate the minimum clock period as follows:
// In commercial designs, the T_c is often dictated by the marketing department to ensure a competitive product.
// The flip-flop clock-to-Q propagation delay and setup time, t_pcq and t_setup, are specified by the manufacturer.
// t_pd is the only variable under the control of the designer.
// How problem can be solved? By increasing the clock period. By redesigning the combinational logic to have a shorter propagation delay.

// Activity and Analysis
// Implement the given 4-bit binary carry lookahead adder in SystemVerilog as follows:
// Write a SystemVerilog module for a 4-bit binary carry lookahead adder and name the module “CLA4”.
// Create a testbench for the module and name this module “CLA4_tb”.
// Use Vivado simulation to verify the functionality of the adder.
// Add a constraint file to your project and synthesize the design.
// Implement the design and generate “Design Analysis” and “Timing” reports.
// Determine the critical and shortest path times.
// Why are the critical path times of both the ripple carry adder and the CLA adder equal? Shouldn't the CLA adder be faster?
