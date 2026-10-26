
`timescale 1ns/1ps

module math_coprocessor(
    input clk, rst, start,
    input [1:0] op,
    input signed [31:0] x,
    output reg signed [31:0] y,
    output reg done, error
);

    parameter ONE = 65536;
    parameter HALF = 32768;
    parameter SIXTH = 10923;
    parameter C24 = 2731;
    parameter C120 = 546;
    parameter C720 = 91;

    function signed [31:0] mul;
        input signed [31:0] a, b;
        reg signed [63:0] temp;
        begin
            temp = a * b;
            mul = temp >>> 16;
        end
    endfunction

    function signed [31:0] exp_x;
        input signed [31:0] a;
        reg signed [31:0] r;
        begin
            r = C720;
            r = C120 + mul(a, r);
            r = C24 + mul(a, r);
            r = SIXTH + mul(a, r);
            r = HALF + mul(a, r);
            r = ONE + mul(a, r);
            r = ONE + mul(a, r);
            exp_x = r;
        end
    endfunction

    function signed [31:0] ln_x;
        input signed [31:0] a;
        reg signed [31:0] z, z2, p, s;
        reg signed [63:0] numerator, denominator;
        begin
            numerator = ($signed(a) - 64'sd65536) <<< 16;
            denominator = $signed(a) + 64'sd65536;
            z = numerator / denominator;

            z2 = mul(z, z);
            p = z;
            s = z;

            p = mul(p, z2);
            s = s + p / 3;

            p = mul(p, z2);
            s = s + p / 5;

            p = mul(p, z2);
            s = s + p / 7;

            p = mul(p, z2);
            s = s + p / 9;

            ln_x = s <<< 1;
        end
    endfunction

    function signed [31:0] sin_x;
        input signed [31:0] a;
        reg signed [31:0] x2, r;
        begin
            x2 = mul(a, a);
            r = -32'sd13;
            r = C120 + mul(x2, r);
            r = -SIXTH + mul(x2, r);
            r = ONE + mul(x2, r);
            sin_x = mul(a, r);
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y <= 0;
            done <= 0;
            error <= 0;
        end
        else begin
            done <= 0;
            error <= 0;

            if (start) begin
                case (op)
                    2'b00: begin
                        if (x >= -131072 && x <= 131072)
                            y <= exp_x(x);
                        else begin
                            y <= 0;
                            error <= 1;
                        end
                    end

                    2'b01: begin
                        if (x >= 32768 && x <= 131072)
                            y <= ln_x(x);
                        else begin
                            y <= 0;
                            error <= 1;
                        end
                    end

                    2'b10: begin
                        if (x >= -98304 && x <= 98304)
                            y <= sin_x(x);
                        else begin
                            y <= 0;
                            error <= 1;
                        end
                    end

                    default: begin
                        y <= 0;
                        error <= 1;
                    end
                endcase

                done <= 1;
            end
        end
    end

endmodule
