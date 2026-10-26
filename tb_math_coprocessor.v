
`timescale 1ns/1ps

module tb_math_coprocessor;

    reg clk, rst, start;
    reg [1:0] op;
    reg signed [31:0] x;

    wire signed [31:0] y;
    wire done, error;

    real result;
    real total_error;
    real tolerance;

    integer passed;
    integer failed;

    math_coprocessor uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .op(op),
        .x(x),
        .y(y),
        .done(done),
        .error(error)
    );

    always #5 clk = ~clk;

    task run_test;
        input [1:0] operation;
        input signed [31:0] input_x;
        input real expected;
        input [8*40-1:0] test_name;

        begin
            @(negedge clk);
            op = operation;
            x = input_x;
            start = 1;

            @(negedge clk);
            start = 0;

            wait(done == 1);

            result = $itor(y) / 65536.0;
            total_error = result - expected;

            if (total_error < 0)
                total_error = -total_error;

            $display("\n----------------------------------------");
            $display("Test            : %0s", test_name);
            $display("Operation       : %b", operation);
            $display("Input           : %f",
                     $itor(input_x) / 65536.0);
            $display("Expected output : %f", expected);
            $display("Hardware output : %f", result);
            $display("Total error     : %f", total_error);
            $display("Error flag      : %b", error);

            if (error == 1) begin
                $display("FAIL: Unexpected hardware error");
                failed = failed + 1;
            end
            else if (total_error <= tolerance) begin
                $display("PASS: Within tolerance");
                passed = passed + 1;
            end
            else begin
                $display("FAIL: Total error exceeds tolerance");
                failed = failed + 1;
            end

            @(negedge clk);
        end
    endtask

    task run_invalid_test;
        input [1:0] operation;
        input signed [31:0] input_x;
        input [8*40-1:0] test_name;

        begin
            @(negedge clk);
            op = operation;
            x = input_x;
            start = 1;

            @(negedge clk);
            start = 0;

            wait(done == 1);

            $display("\n----------------------------------------");
            $display("Test       : %0s", test_name);
            $display("Operation  : %b", operation);
            $display("Input      : %f",
                     $itor(input_x) / 65536.0);
            $display("Error flag : %b", error);

            if (error == 1) begin
                $display("PASS: Invalid input detected");
                passed = passed + 1;
            end
            else begin
                $display("FAIL: Invalid input not detected");
                failed = failed + 1;
            end

            @(negedge clk);
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        op = 0;
        x = 0;

        tolerance = 0.005;
        passed = 0;
        failed = 0;

        repeat (2) @(negedge clk);
        rst = 0;

        $display("========================================");
        $display("   MATH COPROCESSOR VERIFICATION");
        $display("   Tolerance = %f", tolerance);
        $display("========================================");

        $display("\n--- EXPONENTIAL TESTS ---");
        run_test(2'b00,  0,      1.000000, "EXP: x = 0");
        run_test(2'b00,  32768,  1.648721, "EXP: x = 0.5");
        run_test(2'b00, -32768,  0.606531, "EXP: x = -0.5");
        run_test(2'b00,  65536,  2.718282, "EXP: x = 1");

        $display("\n--- NATURAL LOG TESTS ---");
        run_test(2'b01,  32768, -0.693147, "LN: x = 0.5");
        run_test(2'b01,  49152, -0.287682, "LN: x = 0.75");
        run_test(2'b01,  65536,  0.000000, "LN: x = 1");
        run_test(2'b01,  81920,  0.223144, "LN: x = 1.25");
        run_test(2'b01,  98304,  0.405465, "LN: x = 1.5");
        run_test(2'b01, 131072,  0.693147, "LN: x = 2");

        $display("\n--- SINE TESTS ---");
        run_test(2'b10, -98304, -0.997495, "SIN: x = -1.5");
        run_test(2'b10, -65536, -0.841471, "SIN: x = -1");
        run_test(2'b10, -32768, -0.479426, "SIN: x = -0.5");
        run_test(2'b10,  0,       0.000000, "SIN: x = 0");
        run_test(2'b10,  32768,   0.479426, "SIN: x = 0.5");
        run_test(2'b10,  65536,   0.841471, "SIN: x = 1");
        run_test(2'b10,  98304,   0.997495, "SIN: x = 1.5");

        $display("\n--- INVALID INPUT TESTS ---");
        run_invalid_test(2'b01, 0, "LN: x = 0");
        run_invalid_test(2'b00, 196608, "EXP: x = 3");
        run_invalid_test(2'b10, 131072, "SIN: x = 2");
        run_invalid_test(2'b11, 0, "Invalid operation");

        $display("\n========================================");
        $display("FINAL SUMMARY");
        $display("Passed tests : %0d", passed);
        $display("Failed tests : %0d", failed);
        $display("Total tests  : %0d", passed + failed);
        $display("========================================");

        $finish;
    end

endmodule

