module normalLight (lightOn, clk, reset, L, R, NL, NR);
	input  logic clk, reset;
	input  logic L, R;        // button pulses
	input  logic NL, NR;      // neighbor lights
	output logic lightOn;
	
	typedef enum logic [1:0] {OFF=2'b00, ON=2'b01} state_t;
	state_t ps, ns;
	
// determines if LED should turn ON or OFF based on its own state, neighbor's, and button press
// state OFF = light is off, ON = light is ON
// if current LED is OFF, turn ON if
// 1. left neighbor light is ON and right player (R) presses
// 2. right neighbor light is ON and the left plater (L) presses
// if current LED state ON then turn OFF if either player presses
	always_comb begin
		ns = ps;
		case (ps)
			OFF: if (NL & R | NR & L) ns = ON;   // neighbor passes light in
			ON:  if (L | R) ns = OFF;            // light moves away
		endcase
	end

	always_ff @(posedge clk or posedge reset)
		if (reset) ps <= OFF;
		else ps <= ns;

	assign lightOn = (ps == ON); // LED ON when present state is ON
endmodule