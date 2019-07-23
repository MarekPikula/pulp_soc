module counter_wdt
(
	input logic clk_i,
	input logic rst_ni,
	input logic [31:0] init_value_i,
	input logic enable_i,
	input logic clear_i,
	output logic [31:0] counter_value_o
);

	logic [31:0] count;
	logic [31:0] count_mem;

	always_ff@(posedge clk_i, negedge rst_ni)
	begin
		if (~rst_ni)
			count_mem <= init_value_i;
		else
			count_mem <= count;
	end

	always_comb
	begin
		count = count_mem;
		if (clear_i)
		begin
			count = init_value_i;
		end
		else
		begin
			if (enable_i)
			begin
				count = count_mem + 1;
			end
		end
	end

	assign counter_value_o=count_mem;
endmodule
