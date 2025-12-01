#pragma once  
  
#include <stdint.h>  
  
#ifdef __cplusplus  
#include <vector>  
#include <mutex> 
#include <unordered_map> 
#include <string> 
#endif  
  
typedef struct Global_States {  
    double token_time_total;
    double cpu_time_total;
    int decode_cnt;  

#ifdef __cplusplus 
    std::unordered_map<std::string, double> op_max_time_map;
    std::unordered_map<std::string, int> finished_threads_map;
    std::vector<double> cpu_time_records;
    std::vector<double> token_time_records;
    
    Global_States() :  token_time_total(0.0), cpu_time_total(0.0), decode_cnt(0){  
        cpu_time_records.clear();  
        token_time_records.clear();
        finished_threads_map.clear();
        op_max_time_map.clear();
    }  
#endif  
    
} Global_States;
  
#ifdef __cplusplus  
extern "C" {  
#endif  
  
// C-compatible interface functions  
Global_States* get_global_states(void);  
void init_global_states(void);  
void cleanup_global_states(void);  
void export_data(Global_States* states, char * name);
void export_data_batch(Global_States* states, int n_parallel, float t_s);

double op_max_time_map_reader(Global_States* state, const char* key);
void op_max_time_map_writer(Global_States* state, const char* key, double value);
double finished_threads_map_reader(Global_States* state, const char* key);
void finished_threads_map_writer(Global_States* state, const char* key, int value);
  
#ifdef __cplusplus  
}  
#endif