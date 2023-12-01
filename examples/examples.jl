using Revise
using HTTPBenchmarkTool, HTTP

greet()

@elapsed benchmark_dummy("http://localhost:3000", 100, 10000)


