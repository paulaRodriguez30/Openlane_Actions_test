module tt_um_ALU_NicolasOrcasitas (
    input  wire [7:0] ui_in,  // Input numbers
    output reg [7:0] uo_out,   //Output number
    input  wire [7:0] uio_in,   //Control ALU / Select input number
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,     //Clock
    input  wire       rst_n     // Res
);

reg [7:0] A, B;
reg flag, overflow;
reg [5:0] out;

wire [2:0] ALUcontrol;
wire enA, enB;
wire [1:0] flagcontrol;

assign ALUcontrol = uio_in[2:0];
assign enA = uio_in[3];
assign flagcontrol = uio_in[5:4];

assign uio_out[5:0] = out;
assign uio_out[6] = flag;
assign uio_out[7] = overflow;

assign uio_oe = 8'b11111111;

assign enB = ~enA;


// ALU control
always @(*) begin
    case (ALUcontrol)
        3'b000: {out[5:0], uo_out} = A + B;                 // Adition
        3'b001: {out[5:0], uo_out} = A - B;                 // Substraction
        3'b010: {out[5:0], uo_out} = {1'b0, A[7:1]};           // Shift right
        3'b011: {out[5:0], uo_out} = {A[6:0], 1'b0};           // Shift left
        3'b100: {out[5:0], uo_out} = A & B;                 // AND
        3'b101: {out[5:0], uo_out} = A | B;                 // OR
        3'b110: {out[5:0], uo_out} = A ^ B;                 //XOR
        3'b111: {out[5:0], uo_out} = A * B; //Mult
        default: {out[5:0], uo_out} = 14'd0;
    endcase
end


// Flag Control
always @(*) begin
    case (flagcontrol)
        2'b00: flag = A > B;        // Greater than 
        2'b01: flag = A == B;       // Equal
        2'b10: flag = A == 8'd0;    // Equal cero
        2'b11: flag = A[0] == 0;    // Check even
        default: flag = 0;
    endcase
end

// Overflow
always @(*) begin
    if(uio_out[5:0] == 6'd0) begin
        overflow <= 0;
    end       
    else begin
        overflow <= 1;
    end
end

// Input registers

// register A
always @( posedge clk) begin
    if (enA) 
        A <= ui_in;
end
// Resgistrer B
always @( posedge clk) begin
    if (enB) 
        B <= ui_in;
end

// Reset
always @(*) begin
    if (~rst_n)
        A <= 8'd0;
        B <= 8'd0;
        uo_out <= 8'd0;
        out <= 6'd0;
        overflow <= 0;
        flag <= 0;

end
    
endmodule