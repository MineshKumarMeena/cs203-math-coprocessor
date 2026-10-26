
import math

SCALE = 65536

test_cases = [
    ("exp", -1.0),("exp", -0.5),("exp", 0.0),("exp", 0.5),("exp", 1.0),("ln", 0.5),("ln", 0.75),("ln", 1.0),("ln", 1.25),
    ("ln", 1.5),("ln", 2.0),("sin", -1.5),("sin", -1.0),("sin", -0.5),("sin", 0.0),("sin", 0.5),("sin", 1.0),("sin", 1.5),
]

invalid_cases = [("exp", 3.0),("ln", 0.0),("sin", 2.0),("invalid_op", 1.0),]

print("VALID TEST CASES")
print("-" * 75)
print(f"{'Operation':<12}{'Input':<12}{'Input Fixed':<15}{'Expected':<15}{'Expected Fixed'}")

for op, x in test_cases:
    if op == "exp":
        expected = math.exp(x)
    elif op == "ln":
        expected = math.log(x)
    elif op == "sin":
        expected = math.sin(x)

    x_fixed = round(x * SCALE)
    expected_fixed = round(expected * SCALE)

    print(f"{op:<12}{x:<12.4f}{x_fixed:<15}{expected:<15.6f}{expected_fixed}")

print("\nINVALID TEST CASES")
print("-" * 55)
print(f"{'Operation':<15}{'Input':<12}{'Expected y':<15}{'Error flag'}")

for op, x in invalid_cases:
    print(f"{op:<15}{x:<12.4f}{0:<15}{1}")
