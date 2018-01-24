module usb_cypress_master(
                      input logic        clk48,
                      input logic        nreset,
                      // note all control signals are active low in the cypress chip
                      input logic        flaga, // Input fifo of cypress chip is empty (0 empty, 1 not empty)
                      /* verilator lint_off unused */
                      input logic        flagb,
                      input logic        flagc,
                      /* verilator lint_on unused */
                      input logic        flagd, // Input fifo of cypress chip is full (0 full, 1 not full)
                      output logic [1:0] faddr, // These signals select the active endpoint.
                      output logic       sloe, // This is the enable signal for the FIFO‟s output driver.
                      output logic       slwr, // SLWR pin should be asserted by the master to write data to the FIFO.
                      output logic       slrd, // SLRD pin should be asserted by the master to read data from the FIFO.
                      inout [7:0]        fdata, // 8-bit i/o data bus.
                      // tx direction
                      input              tx_valid,
                      output             tx_ready,
                      input [7:0]        tx_data,
                      // rx direction
                      output             rx_valid,
                      input              rx_ready,
                      output [7:0]       rx_data
);
   // See Cypress application note AN61345

   typedef enum logic [1:0] {
                             IDLE,
                             WRITE_USB,
                             READ_USB
                             } state_t;
   state_t state = IDLE;
   state_t next_state;
   logic writing;
   assign writing = (state == WRITE_USB);

   always_comb begin
      // default assignments
      next_state = state;
      // make read channel the default
      faddr = 2'b00;
      // active low signals
      slwr = 1'b1;
      slrd = 1'b1;
      sloe = 1'b1;
      // signals to clients
      rx_valid = 1'b0;
      tx_ready = 1'b0;
      unique case (state)
        IDLE: begin
           if (flaga) begin
              // input fifo contains data
              next_state = READ_USB;
           end else if (tx_valid) begin
              // there is data to be transmitted
              next_state = WRITE_USB;
           end
        end
        READ_USB: begin
           // output channel of the cypress chip is 2'b00
           faddr = 2'b00;
           slwr = 1'b1;
           rx_valid = 1'b1;
           if ((flaga == 1'b0) & rx_ready) begin
              // input fifo is empty & client has seen the data
              next_state = IDLE;
           end else if (rx_ready) begin
              // we can accept the next word
              slrd = 1'b0;
              sloe = 1'b0;
           end else begin
              // rx is not ready, stall
           end
        end
        WRITE_USB: begin
           // input channel to cypress chip is 2'b10
           faddr = 2'b10;
           if (flagd & tx_valid) begin
              // output fifo is full, stall
           end else if (tx_valid) begin
              slwr = 1'b0;
              tx_ready = 1'b1;
           end else begin
              next_state = IDLE;
           end
        end // case: WRITE_USB
        default: begin
           next_state = 'z;
        end
      endcase
   end

   assign fdata = writing ? tx_data : 'z;
   assign rx_data = writing ? '0 : fdata;

   always_ff @(posedge clk48) begin
      if (nreset) begin
         state <= next_state;
      end else begin
         state <= IDLE;
      end
   end
endmodule
