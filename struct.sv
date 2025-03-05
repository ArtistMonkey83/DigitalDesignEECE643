// NOT Gate
module not_gate(
    input logic a,
    output logic y
);
    assign y = ~a;
endmodule

// NAND Gate
module nand_gate(
    input logic a,
    input logic b,
    output logic y
);
    assign y = ~(a & b);
endmodule

// NOR Gate
module nor_gate(
    input logic a,
    input logic b,
    output logic y
);
    assign y = ~(a | b);
endmodule

// XNOR Gate
module xnor_gate(
    input logic a,
    input logic b,
    output logic y
);
    assign y = ~(a ^ b);
endmodule

module structural_model(
    input logic clk,
    input logic reset,
    output logic a, b, c, y
);

    // Internal connections
    logic not_a, not_b, not_c;

    // Instantiate gates
    nor_gate nor1(.a(c), .b(b), .y(a));
    not_gate not1(.a(a), .y(not_a));
    not_gate not2(.a(c), .y(not_c));
    nand_gate nand1(.a(not_a), .b(not_c), .y(b));
    not_gate not3(.a(b), .y(not_b));
    xnor_gate xnor1(.a(a), .b(not_b), .y(c));
    nor_gate nor2(.a(not_b), .b(not_a), .y(y));

endmodule
