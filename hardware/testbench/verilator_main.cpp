//
// Copyright 2011-2015 Jeff Bush
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include <iostream>
#include <stdlib.h>
#include "Vsoc_tb.h"
#include "verilated.h"
#include "verilated_vpi.h"
#if VM_TRACE
#include <verilated_vcd_c.h>
#endif
using namespace std;

//
// This is compiled into the verilog simulator executable along with the
// source files generated by Verilator. It initializes and runs the simulation
// loop.
//

namespace
{
vluint64_t currentTime = 0;
}

// Called whenever the $time variable is accessed.
double sc_time_stamp()
{
    return currentTime;
}

int main(int argc, char **argv, char **env)
{
    Verilated::commandArgs(argc, argv);
    Verilated::debug(0);

    // Default to randomizing contents of memory before the start of
    // simulation. This flag can disable it.
    const char *arg = Verilated::commandArgsPlusMatch("randomize=");
    if (arg[0] == '\0' || atoi(arg + 11) != 0)
    {
        // Initialize random seed.
        long randomSeed;
        arg = Verilated::commandArgsPlusMatch("randseed=");
        if (arg[0] != '\0')
            randomSeed = atol(arg + 10);
        else
        {
            time_t t1;
            time(&t1);
            randomSeed = (long) t1;
        }

        srand48(randomSeed);
        VL_PRINTF("Random seed is %li\n", randomSeed);
        Verilated::randReset(2);
    }
    else
        Verilated::randReset(0);

    Vsoc_tb* testbench = new Vsoc_tb;

    // As with real hardware, reset is a bit tricky. In order for the
    // reset blocks to execute, there must be a rising edge on reset.
    // Previously, I did this in the main loop, but if there is a rising
    // edge on clock before reset occurs, the processor would be in an
    // undefined state (because we randomized all of the flops with
    // randReset above), and often trip assertions. Instead, I assert and
    // deassert reset before toggling clock. This also ensures it has
    // proper asynchronous behavior, since, in previously, the reset
    // block would execute synchronously on the next clock edge.
    testbench->reset = 0;
    testbench->clk = 0;
    testbench->eval();
    testbench->reset = 1;
    testbench->eval();
    testbench->reset = 0;
    testbench->eval();

#if VM_TRACE // If verilator was invoked with --trace
    Verilated::traceEverOn(true);
    VL_PRINTF("Writing waveform to trace.vcd\n");
    VerilatedVcdC* tfp = new VerilatedVcdC;
    testbench->trace(tfp, 99);
    tfp->open("trace.vcd");
#endif

    while (!Verilated::gotFinish())
    {
        testbench->clk = !testbench->clk;
        testbench->eval();
#if VM_TRACE
        tfp->dump(currentTime); // Create waveform trace for this timestamp
#endif

        currentTime++;
    }

#if VM_TRACE
    tfp->close();
#endif

    testbench->final();
    delete testbench;

    return 0;
}
