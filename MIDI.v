module MIDI(
		signal, clk, rst_n,
		flag, clk_local,flag7,
		case1, case2, case3, correct, test_cnt_frame,
		LED,alert
		);
input signal, clk, rst_n;
output reg[7:0] LED;


reg[7:0] cnt;  //cnt, used for freq_divider, based on global clk
reg[10:0] cnt_frame; //cnt_frame, count 10 bits to reset flag, based on global clk
reg [3:0] pointer; //point to correct data address
reg [9:0] Data; //temp for signal 
reg [1:0] state, next_state; 
reg [3:0] count_7;


//The following output is used to test
output clk_local;
output reg flag;   
output reg flag7;
output reg case1, case2, case3, correct;
output reg test_cnt_frame;
output reg alert;

parameter [1:0] frame1 = 2'd1, frame2 = 2'd2;

//Program starts here
initial case1 = 1'd0;
initial case2 = 1'd0;
initial case3 = 1'd0;
initial correct = 1'd0;




	always @(negedge clk or negedge rst_n)    //cnt, freq_divider
		if(!rst_n) cnt <= 8'd0;
		else if (flag == 1'b0) cnt <= 8'd0;
		else if (cnt <= 8'd127) cnt <= cnt + 1'd1;
		else cnt <= 8'd1;
	
	assign  clk_local = ( cnt <= 8'd64) ? 1'b0 : 1'b1;  // generate local clk
	
	
	
	
	
	
	always @(negedge signal or negedge rst_n or negedge test_cnt_frame)    //flag
		if(!rst_n) flag <= 1'd0;
		else if(!signal) flag <= 1'd1;
		else if(!test_cnt_frame) flag <= 1'd0;

		
	always @(negedge rst_n or negedge flag or posedge clk) //cnt_frame
		if (!rst_n) 
		cnt_frame <= 11'd1;
		else if(flag == 1'b0) cnt_frame <= 11'd1;
		else if( cnt_frame <= 11'd1280)  cnt_frame <= cnt_frame + 1'd1;
		else cnt_frame <= 11'd1;
	
	always @(negedge rst_n or posedge clk) //test_cnt_frame, Used to check whether cnt_frame will count 1280
		if(!rst_n) test_cnt_frame <= 1'd1;
		else if(cnt_frame >= 11'd1250) test_cnt_frame <= 1'd0;
		else test_cnt_frame <= 1'd1; 	
		
		
		
		
		
	always @(posedge clk_local or negedge rst_n or negedge flag) //pointer
		if(!rst_n) pointer <= 4'd0;
		else if(!flag) pointer <= 4'd0;
		else if(pointer <= 4'd9) pointer <= pointer + 4'd01;
		else pointer <= 4'd0;
		
	always @(posedge clk_local or negedge flag or negedge rst_n) // Data, assign signal to data
		if(!rst_n) Data <= 10'd0;
		else if(!flag) Data <= 10'd0;
		else Data[pointer] <= signal;
		

		
	always @(posedge clk) //flag7
	if(cnt_frame >= 1152 && cnt_frame <= 1280) flag7 <= 1'd1;
	else flag7 <= 1'd0;
	
	always @(posedge clk or negedge rst_n) //rst state
		begin
			if(!rst_n) state <= frame1;
			else state <= next_state;
		end	
	
	always @(posedge flag7)   
	case(state)
		frame1: begin
				case1 <= 1'd1;
			if(Data[8] == 1'd1) begin
			next_state <= frame2;
			end
			else begin
			next_state <= frame1;
			end
				end
		frame2: begin
				case2 <=1'd1;
			if(Data[8] == 1'd0) begin
			correct <= 1'd1;
			next_state <= frame1;
			end
			else begin
			next_state <= frame1;
			end
				end
		default:begin
			next_state <= frame1;
			end
	endcase	
	
	
	
	
	always @(posedge correct or negedge rst_n)
		if(!rst_n) 
			begin
				LED[0] <= 1'd1;
				LED[1] <= 1'd1;
				LED[2] <= 1'd1;
				LED[3] <= 1'd1;
				LED[4] <= 1'd1;
				LED[5] <= 1'd1;
				LED[6] <= 1'd1;
				LED[7] <= 1'd1;
				
			end
			
		else if(correct == 1'd1)
			begin
				LED[0] <= Data[1];
				LED[1] <= Data[2];
				LED[2] <= Data[3];
				LED[3] <= Data[4];
				LED[4] <= Data[5];
				LED[5] <= Data[6];
				LED[6] <= Data[7];
				LED[7] <= Data[8];
			end
			
	
	always @(negedge flag or negedge rst_n)
		if(!rst_n) alert <= 1'd1;
		else if(!flag) alert <= 1'd0;
		else alert <= 1'd1;
		


endmodule
