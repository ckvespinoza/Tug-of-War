module button_sync (pressed_pulse, clk, async_button);
	output logic pressed_pulse;
	input  logic clk;
	input  logic async_button;
	
	logic ff1, ff2;

	always_ff @(posedge clk) begin
		ff1 <= async_button;
		ff2 <= ff1;
	end

	// Positive edge detection
	assign pressed_pulse = ff1 & ~ff2;
endmodule