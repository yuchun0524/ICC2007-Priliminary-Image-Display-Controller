module lcd_ctrl(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output  reg     [7:0]dataout;
output  reg     output_valid;
output  reg     busy;
reg   [7:0]buffer[35:0];   
reg   [5:0]count;
reg   [3:0]out_count;
reg   [5:0]origin;
reg   valid;

parameter reflash = 3'd0,
          load = 3'd1,
          right = 3'd2,
          left = 3'd3,
          up = 3'd4,
          down = 3'd5;  
integer i;

always@(posedge clk)
  begin
    if(reset)
      begin
        origin <= 6'd0;
        valid <= 1'b0;
        output_valid <= 1'b0;  
        out_count <= 4'd0; 
        busy <= 1'b0;      
        count <= 6'd0;  
        for(i = 0; i < 36; i = i + 1)
          begin
            buffer[i] <= 0;
        end 
    end
    else
      begin
        if(cmd_valid)
          begin
            if(!busy)
              begin
                busy <= 1'b1;
                case(cmd)
                  reflash:begin
                    origin <= origin;
                    output_valid <= 1'b1;
                  end
                  load:begin          
                    origin <= 6'd14;
                    valid <= 1'b1;  
                    output_valid <= 1'b0; 
                  end
                  right:begin
                    if(origin == 6'd3 || origin == 6'd9 || origin == 6'd15 || origin == 6'd21)
                      origin <= origin;
                    else
                      origin <= origin + 1;
                    output_valid <= 1'b1;
                  end
                  left:begin
                    if(origin == 6'd0 || origin == 6'd6 || origin == 6'd12 || origin == 6'd18)
                      origin <= origin;
                    else
                      origin <= origin - 1;
                    output_valid <= 1'b1;
                  end
                  up:begin
                    if(origin == 6'd0 || origin == 6'd1 || origin == 6'd2 || origin == 6'd3)
                      origin <= origin;
                    else
                      origin <= origin - 6;
                    output_valid <= 1'b1;
                  end
                  down:begin
                    if(origin == 6'd18 || origin == 6'd19 || origin == 6'd20 || origin == 6'd21)
                      origin <= origin;
                    else
                      origin <= origin + 6;
                    output_valid <= 1'b1;
                  end
                  default:begin
                    origin <= origin;
                    output_valid <= 1'b0;
                  end
                endcase
            end
            else
              begin
                origin <= origin;
                valid <= valid;
                output_valid <= output_valid;
            end
        end 
        else
          begin
            output_valid <= output_valid;
            origin <= origin;
            valid <= valid;
            if(valid)
              begin
                busy <= 1'b1;
                if(count == 6'd36)
                  begin
                    count <= count;
                    output_valid <= 1'b1;
                    valid <= 1'b0;
                end
       	        else
                  begin         
                    buffer[count] <= datain;
                    count <= count + 1;
                    output_valid <= 1'b0;
                end
            end
            else
              begin
                if(output_valid)
                  begin  
                    if(out_count == 4'd8)
                      begin                     
                        busy <= 1'b0;
                        output_valid <= 1'b0;
                        out_count <= 4'd0;
                        count <= 6'd0;
                        origin <= origin - 14;
                    end
                    else 
                      begin                       
              	         busy <= 1'b1;
              	         out_count <= out_count + 1'b1;
                        if(out_count == 4'd2 || out_count == 4'd5)
              	           begin
                            origin <= origin + 4;
                        end               	 	 	
                        else
                          begin             
                            origin <= origin + 1; 
                    	   end
                    end
                end
                else
                  begin
                    origin <= origin;
                    valid <= valid;
                   	output_valid <= output_valid;
                end
          	 end
        end
    end
end  
always@(negedge clk)
begin
  if(reset)
      dataout <= 8'd0;     
  else
    begin
    if(valid)
        dataout <= 8'd0;
    else
        dataout <= buffer[origin];
  end 
end                                                                             
endmodule