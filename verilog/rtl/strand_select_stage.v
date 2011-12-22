//
// This is currently stubbed out for one thread.  When multiple threads
// are added, it will need to choose one thread each cycle and dispatch it.
//

module strand_select_stage(
	input					clk,

	input [31:0]			instruction0_i,
	input					instruction_valid0_i,
	input [31:0]			pc0_i,
	input					flush0_i,
	input					suspend_strand0_i,
	input					resume_strand0_i,
	output					next_instruction0_o,
	input [31:0]			rollback_strided_offset0_i,
	input [3:0]				rollback_reg_lane0_i,

	input [31:0]			instruction1_i,
	input					instruction_valid1_i,
	input [31:0]			pc1_i,
	input					flush1_i,
	input					suspend_strand1_i,
	input					resume_strand1_i,
	output					next_instruction1_o,
	input [31:0]			rollback_strided_offset1_i,
	input [3:0]				rollback_reg_lane1_i,

	input [31:0]			instruction2_i,
	input					instruction_valid2_i,
	input [31:0]			pc2_i,
	input					flush2_i,
	input					suspend_strand2_i,
	input					resume_strand2_i,
	output					next_instruction2_o,
	input [31:0]			rollback_strided_offset2_i,
	input [3:0]				rollback_reg_lane2_i,

	input [31:0]			instruction3_i,
	input					instruction_valid3_i,
	input [31:0]			pc3_i,
	input					flush3_i,
	input					suspend_strand3_i,
	input					resume_strand3_i,
	output					next_instruction3_o,
	input [31:0]			rollback_strided_offset3_i,
	input [3:0]				rollback_reg_lane3_i,

	output reg[31:0]		pc_o = 0,
	output reg[31:0]		instruction_o = 0,
	output reg[3:0]			reg_lane_select_o = 0,
	output reg[31:0]		strided_offset_o = 0,
	output reg[1:0]			strand_id_o = 0);

	wire[31:0]				pc0;
	wire[31:0]				instruction0;
	wire[3:0]				reg_lane_select0;
	wire[31:0]				strided_offset0;
	wire[31:0]				pc1;
	wire[31:0]				instruction1;
	wire[3:0]				reg_lane_select1;
	wire[31:0]				strided_offset1;
	wire[31:0]				pc2;
	wire[31:0]				instruction2;
	wire[3:0]				reg_lane_select2;
	wire[31:0]				strided_offset2;
	wire[31:0]				pc3;
	wire[31:0]				instruction3;
	wire[3:0]				reg_lane_select3;
	wire[31:0]				strided_offset3;
	wire					request0;
	wire					request1;
	wire					request2;
	wire					request3;
	wire					grant0;
	wire					grant1;
	wire					grant2;
	wire					grant3;

	strand_fsm s0(
		.clk(clk),
		.instruction_i(instruction0_i),
		.instruction_valid_i(instruction_valid0_i),
		.grant_i(grant0),
		.issue_request_o(request0),
		.pc_i(pc0_i),
		.flush_i(flush0_i),
		.next_instruction_o(next_instruction0_o),
		.suspend_strand_i(suspend_strand0_i),
		.resume_strand_i(resume_strand0_i),
		.rollback_strided_offset_i(rollback_strided_offset0_i),
		.rollback_reg_lane_i(rollback_reg_lane0_i),
		.pc_o(pc0),
		.instruction_o(instruction0),
		.reg_lane_select_o(reg_lane_select0),
		.strided_offset_o(strided_offset0));

	strand_fsm s1(
		.clk(clk),
		.instruction_i(instruction1_i),
		.instruction_valid_i(instruction_valid1_i),
		.grant_i(grant1),
		.issue_request_o(request1),
		.pc_i(pc1_i),
		.flush_i(flush1_i),
		.next_instruction_o(next_instruction1_o),
		.suspend_strand_i(suspend_strand1_i),
		.resume_strand_i(resume_strand1_i),
		.rollback_strided_offset_i(rollback_strided_offset1_i),
		.rollback_reg_lane_i(rollback_reg_lane1_i),
		.pc_o(pc1),
		.instruction_o(instruction1),
		.reg_lane_select_o(reg_lane_select1),
		.strided_offset_o(strided_offset1));

	strand_fsm s2(
		.clk(clk),
		.instruction_i(instruction2_i),
		.instruction_valid_i(instruction_valid2_i),
		.grant_i(grant2),
		.issue_request_o(request2),
		.pc_i(pc2_i),
		.flush_i(flush2_i),
		.next_instruction_o(next_instruction2_o),
		.suspend_strand_i(suspend_strand2_i),
		.resume_strand_i(resume_strand2_i),
		.rollback_strided_offset_i(rollback_strided_offset2_i),
		.rollback_reg_lane_i(rollback_reg_lane2_i),
		.pc_o(pc2),
		.instruction_o(instruction2),
		.reg_lane_select_o(reg_lane_select2),
		.strided_offset_o(strided_offset2));

	strand_fsm s3(
		.clk(clk),
		.instruction_i(instruction3_i),
		.instruction_valid_i(instruction_valid3_i),
		.grant_i(grant3),
		.issue_request_o(request3),
		.pc_i(pc3_i),
		.flush_i(flush3_i),
		.next_instruction_o(next_instruction3_o),
		.suspend_strand_i(suspend_strand3_i),
		.resume_strand_i(resume_strand3_i),
		.rollback_strided_offset_i(rollback_strided_offset3_i),
		.rollback_reg_lane_i(rollback_reg_lane3_i),
		.pc_o(pc3),
		.instruction_o(instruction3),
		.reg_lane_select_o(reg_lane_select3),
		.strided_offset_o(strided_offset3));

	arbiter4 issue_arb(
		.clk(clk),
		.req0_i(request0),

`ifdef ENABLE_MULTI_STRAND
		.req1_i(request1),
		.req2_i(request2),
		.req3_i(request3),
`else
		.req1_i(0),
		.req2_i(0),
		.req3_i(0),
`endif
		.grant0_o(grant0),
		.grant1_o(grant1),
		.grant2_o(grant2),
		.grant3_o(grant3));

	// Output mux (XXX hard coded to first strand for now)
	always @(posedge clk)
	begin
		if (grant0)
		begin
			pc_o				<= #1 pc0;
			instruction_o		<= #1 instruction0;
			reg_lane_select_o	<= #1 reg_lane_select0;
			strided_offset_o	<= #1 strided_offset0;
			strand_id_o			<= #1 0;
		end
		else if (grant1)
		begin
			pc_o				<= #1 pc1;
			instruction_o		<= #1 instruction1;
			reg_lane_select_o	<= #1 reg_lane_select1;
			strided_offset_o	<= #1 strided_offset1;
			strand_id_o			<= #1 1;
		end
		else if (grant2)
		begin
			pc_o				<= #1 pc2;
			instruction_o		<= #1 instruction2;
			reg_lane_select_o	<= #1 reg_lane_select2;
			strided_offset_o	<= #1 strided_offset2;
			strand_id_o			<= #1 2;
		end
		else if (grant3)
		begin
			pc_o				<= #1 pc3;
			instruction_o		<= #1 instruction3;
			reg_lane_select_o	<= #1 reg_lane_select3;
			strided_offset_o	<= #1 strided_offset3;
			strand_id_o			<= #1 3;
		end
		else
		begin
			// No strand is ready, issue NOP
			pc_o 				<= #1 0;
			instruction_o 		<= #1 0;
			reg_lane_select_o 	<= #1 0;
			strided_offset_o 	<= #1 0;
			strand_id_o			<= #1 0;
		end
	end
endmodule
