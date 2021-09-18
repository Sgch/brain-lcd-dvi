parameter T_PON_RESET_NEGATE = 1/*5*/ * 1000 * 1000; // 15ms  
parameter T_PON_RESET_ASSERT = 1/*5*/ * 1000 * 1000; // 15ms  

// reset task
task task_reset;
    begin
        wr    = 1'b1;
        rs    = 1'b1;
        cs_n  = 1'b1;
        data  = 16'hxxxx;
        #(5*1000);

        rst_n = 1'b1;
        #(T_PON_RESET_ASSERT);
        
        rst_n = 1'b0;
        #(T_PON_RESET_NEGATE);
        
        rst_n = 1'b1;
    end
endtask

// write task
task task_write;
    input         is_data;
    input [ 7: 0] cmd_data;
    begin
        rs = 1'b0 | is_data;
        #(40); // 40ns

        cs_n = 1'b0;
        #(32); // 32ns

        wr = 1'b0;
        #(40-32); // 8ns (40-32)

        data = {8'h00, cmd_data};
        #(40-8);  // 32ns (40-8)

        wr = 1'b1;
        #(40-8);  // 32ns (40-8)
        
        data = 16'hxxxx;
        #(40-32); // 8ns (40-32)

        cs_n = 1'b1;
        #(40); // 40ns

        rs = 1'b1;
    end
endtask

// Command: 2A
task write_column_address_set;
    input [15: 0] start_address;
    input [15: 0] end_address;
    begin
        // Column Address Set
        task_write(1'b0, 8'h2a);
        #(T_TRANSFER_INTERVAL);

        // Start Column Address
        task_write(1'b1, start_address[15: 8]);
        #(T_TRANSFER_INTERVAL);
        task_write(1'b1, start_address[ 7: 0]);
        #(T_TRANSFER_INTERVAL);

        // End Column Address
        task_write(1'b1, end_address[15: 8]);
        #(T_TRANSFER_INTERVAL);
        task_write(1'b1, end_address[ 7: 0]);
        #(T_TRANSFER_INTERVAL);
    end
endtask

// Command: 2B
task write_page_address_set;
    input [15: 0] start_address;
    input [15: 0] end_address;
    begin
        // Page Address Set
        task_write(1'b0, 8'h2b);
        #(T_TRANSFER_INTERVAL);

        // Start Page Address
        task_write(1'b1, start_address[15: 8]);
        #(T_TRANSFER_INTERVAL);
        task_write(1'b1, start_address[ 7: 0]);
        #(T_TRANSFER_INTERVAL);

        // End Page Address
        task_write(1'b1, end_address[15: 8]);
        #(T_TRANSFER_INTERVAL);
        task_write(1'b1, end_address[ 7: 0]);
        #(T_TRANSFER_INTERVAL);
    end
endtask

// Command: 2C
task wirte_start_transfer;
    begin
        task_write(1'b0, 8'h2c);
        #(T_TRANSFER_INTERVAL);
    end
endtask

// Send pixel data
task write_pixel;
    input [15: 0] pixel;
    begin
        wr = 1'b0;
        #(8);

        data = pixel;
        #(32);

        wr = 1'b1;
        #(32);

        data = 16'hxxxx;
        #(8);
    end
endtask

task send_screen;
    input [15: 0] start_pix;
    input [15: 0] end_pix;
    integer i;
    begin
        rs = 1'b1;
        cs_n = 1'b0;
        #(40); // 40ns

        for (i = 0; i < start_pix*end_pix; i = i + 1) begin
            write_pixel(i);
        end

        #(40); // 40ns
        cs_n = 1'b1;
    end
endtask