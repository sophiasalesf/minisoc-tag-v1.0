
package minisoc_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import clock_agent_pkg::*;
  import reset_agent_pkg::*;

  `include "minisoc_clock_checker.sv"
  `include "minisoc_reset_checker.sv"
  `include "minisoc_env.sv"

endpackage : minisoc_env_pkg