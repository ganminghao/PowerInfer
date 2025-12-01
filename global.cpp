#include "global.h"  
#include <cstdlib>  
#include <mutex>  
#include <string>

  
static Global_States* g_instance = nullptr;  
static std::mutex g_mutex;  

// 这些函数必须在 extern "C" 块中实现，与 global.h 的声明对应
extern "C" {
double op_max_time_map_reader(Global_States* state, const char* key) {
    // if (!state) return 0.0;
    std::string cpp_key(key);
    return state->op_max_time_map[cpp_key];
}

void op_max_time_map_writer(Global_States* state, const char* key, double value) {
    // if (!state) return;
    std::string cpp_key(key);
    state->op_max_time_map[cpp_key] = value;
}


double finished_threads_map_reader(Global_States* state, const char* key) {
    // if (!state) return 0.0;
    std::string cpp_key(key);
    return (double)state->finished_threads_map[cpp_key];
}

void finished_threads_map_writer(Global_States* state, const char* key, int value) {
    if (!state) return;
    std::string cpp_key(key);
    state->finished_threads_map[cpp_key] = value;
}
} // extern "C"
  
extern "C" {  
  
Global_States* get_global_states(void) {  
    if (!g_instance) {  
        init_global_states();  
    }  
    return g_instance;  
}  
  
void init_global_states(void) {  
    if (!g_instance) {  
        g_instance = new Global_States();  
    }  
}  

void export_data(Global_States* states, char * fname) {
    std::lock_guard<std::mutex> lock(g_mutex);
    // export cpu_time_records to a csv file:
    printf("Exporting time_records to %s\n", fname);
    FILE* fp = fopen(fname, "w");
    if (fp) {
        // Write headers
        fprintf(fp, "CPU Time Records,Token Time Records\n");

        // Determine the maximum size between the two vectors
        size_t max_size = std::max(states->cpu_time_records.size(), states->token_time_records.size());

        // Write data row by row
        for (size_t i = 0; i < max_size; i++) {
            double cpu_time = (i < states->cpu_time_records.size()) ? states->cpu_time_records[i] : 0.0;
            double token_time = (i < states->token_time_records.size()) ? states->token_time_records[i] : 0.0;
            fprintf(fp, "%f,%f\n", cpu_time, token_time);
        }

        fclose(fp);
    }
}

void export_data_batch(Global_States* states, int batch_size, float t_s) {
    std::lock_guard<std::mutex> lock(g_mutex);
    // Open the batch.csv file in append mode
    FILE* fp = fopen("batch.csv", "a+");
    if (fp) {
        // Check if the file is empty (first time creation)
        fseek(fp, 0, SEEK_END);
        if (ftell(fp) == 0) {
            // Write the header
            fprintf(fp, "batchsize,throughput,CPU-latency-ratio\n");
        }

        // Calculate throughput and CPU-latency-ratio
        float cpu_latency_ratio = 0.0;
        if (!states->cpu_time_records.empty() && !states->token_time_records.empty()) {
            cpu_latency_ratio = states->cpu_time_records[0] / states->token_time_records[0];
        }

        // Append the data
        fprintf(fp, "%d,%f,%f\n", batch_size, t_s, cpu_latency_ratio);

        fclose(fp);
    }
}
}

  
void cleanup_global_states(void) { 
    delete g_instance;  
    g_instance = nullptr;  
}  