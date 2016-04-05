// Full Adder
module fa(sum, cout, a, b, cin);
output sum, cout;
input a, b, cin;
wire aorb, gen, prop;
xor(sum, a, b, cin); // sum
and(gen, a, b);      // generate
or(aorb, a, b);      // propogate
and(prop, aorb, cin);
or(cout, gen, prop); // cout
endmodule

// ripple carry ADD, 8-bit
module add8(sum, a, b);
output [7:0] sum;
input [7:0] a, b;
wire [7:0] cout;
fa fa0(sum[0], cout[0], a[0], b[0], 0),
   fa1(sum[1], cout[1], a[1], b[1], cout[0]),
   fa2(sum[2], cout[2], a[2], b[2], cout[1]),
   fa3(sum[3], cout[3], a[3], b[3], cout[2]),
   fa4(sum[4], cout[4], a[4], b[4], cout[3]),
   fa5(sum[5], cout[5], a[5], b[5], cout[4]),
   fa6(sum[6], cout[6], a[6], b[6], cout[5]),
   fa7(sum[7], cout[7], a[7], b[7], cout[6]);
endmodule

// signed SATuration ADD, 8-bit
module satadd8(sum, a, b);
output reg [7:0] sum;
input [7:0] a, b;
wire [7:0] modsum;
add8 modadd8(modsum, a, b);
always @(modsum) begin
  if ((a[7] == b[7]) &&
      (a[7] != modsum[7])) begin
    if (modsum[7]) sum = 127;
    else sum = -128;
  end else begin
    sum = modsum;
  end
end
endmodule

// REFerence signed SATuration ADD, 8-bit
module refsatadd8(s, a, b);
output reg signed [7:0] s;
input signed [7:0] a, b;
reg signed [8:0] t;
always @* begin
  t = a + b;                 // 9-bit result
  if (t < -128) s = -128;    // signed less than
  else if (t > 127) s = 127; // signed greater than
  else s = t[7:0];
end
endmodule

// TEST BENCH
module testbench;
reg signed [7:0] a, b, s, sref;
integer correct = 0;
integer failed = 0;
wire [7:0] sw, swref;
satadd8 uut(sw, a, b);
refsatadd8 oracle(swref, a, b);
initial begin
  a=0;
  repeat (256) begin
    b=0;
    repeat (256) #1 begin
      s = sw;
      sref = swref;
      if (s != sref) begin
        $display("Wrong: %d+%d=%d, but got %d", a, b, sref, s);
        failed = failed + 1;
      end else begin
        correct = correct + 1;
      end
      b = b + 1;
    end
    a = a + 1;
  end
  $display("All cases tested; %d correct, %d failed", correct, failed);
end
endmodule
