include("SpectralRefinement.jl")

partitioner = "autotune_hmetis"
benchmark = "Titan"

UBfactor_list = [10]
Nparts_list = [2]
eig_vecs_list = [2] # number of eigenvalues
num_cycles_list = [2]  # number of cycles used for converting hypergraph
h_threshold_list = [300] # threshold of number of hyperedges in the clustered_hypergraph for ILP solver
solver_iters_list = [80] # number of iterations in the eigenvalue solvers
#spec_iters_list = [3, 2, 1] # number of iterations for the spectral framework
#best_solns_list = [10, 8, 6, 4, 2] # number of best partition solutions used for cut elimination
spec_iters_list = [2] #, 3, 4, 5] # number of iterations for the spectral framework
best_solns_list = [5] # number of best partition solutions used for cut elimination
seed_list = [0] # random seed

work_dir = pwd()
work_dir *= "/autotune_hmetis_rpt_julia_titan/"

if isdir(work_dir) == false
    mkdir(work_dir)
end

result_file = work_dir * partitioner * "_" * benchmark * "_summary_file.txt"
julia_exe = "/home/bodhi91/sandbox/software/julia-1.6.0-linux-x86_64/julia-1.6.0/bin/julia"
hmetis_exe = pwd() * "/hmetis"
patoh_exe = pwd() * "/patoh"
kahypar_exe = pwd() * "/KaHyPar"
kahypar_config = "/home/bodhi91/sandbox/Partitioners/IterativeSpectralRefinement/cut_rKaHyPar_sea20.ini"
design_list = String[]
benchmark_dir = "/home/bodhi91/sandbox/Partitioners/Benchmarks/" * benchmark * "/"

design_list = ["bitcoin_miner",
                "bitonic_mesh",
                "cholesky_bdti",
                "cholesky_mc",
                "dart",
                "denoise",
                "des90",
                "directrf",
                "gsm_switch",
                "LU230",
                "LU_Network",
                "mes_noc",
                "minres",
                "neuron",
                "openCV",
                "segmentation",
                "SLAM_spheric",
                "sparcT1_chip2",
                "sparcT1_core",
                "sparcT2_core",
                "stap_qrd",
                "stereo_vision"]

solutions_path = "/home/bodhi91/sandbox/Partitioners/SpecPart-Results/solutions/Titan23_benchmark_solutions/hMetis_Autotune/UBfactor_10/"

partitions = [solutions_path * "bitcoin_miner/" * "CType=5,Nparts=2,RType=1,Reconst=0,UBfactor=10,Vcycle=3/bitcoin_miner.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "bitonic_mesh/" * "CType=2,Nparts=2,RType=1,Reconst=1,UBfactor=10,Vcycle=3/bitonic_mesh.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "cholesky_bdti/" * "CType=3,Nparts=2,RType=2,Reconst=0,UBfactor=10,Vcycle=2/cholesky_bdti.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "cholesky_mc/" * "CType=2,Nparts=2,RType=2,Reconst=0,UBfactor=10,Vcycle=2/cholesky_mc.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "dart/" * "CType=1,Nparts=2,RType=1,Reconst=1,UBfactor=10,Vcycle=2/dart.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "denoise/" * "CType=4,Nparts=2,RType=2,Reconst=1,UBfactor=10,Vcycle=2/denoise.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "des90/" * "CType=2,Nparts=2,RType=1,Reconst=0,UBfactor=10,Vcycle=1/des90.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "directrf/" * "CType=1,Nparts=2,RType=3,Reconst=0,UBfactor=10,Vcycle=1/directrf.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "gsm_switch/" * "CType=4,Nparts=2,RType=2,Reconst=0,UBfactor=10,Vcycle=2/gsm_switch.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "LU230/" * "CType=1,Nparts=2,RType=2,Reconst=0,UBfactor=10,Vcycle=3/LU230.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "LU_Network/" * "CType=5,Nparts=2,RType=2,Reconst=1,UBfactor=10,Vcycle=1/LU_Network.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "mes_noc/" * "CType=2,Nparts=2,RType=3,Reconst=1,UBfactor=10,Vcycle=1/mes_noc.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "minres/" * "CType=1,Nparts=2,RType=2,Reconst=0,UBfactor=10,Vcycle=1/minres.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "neuron/" * "CType=1,Nparts=2,RType=2,Reconst=1,UBfactor=10,Vcycle=3/neuron.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "openCV/" * "CType=2,Nparts=2,RType=3,Reconst=1,UBfactor=10,Vcycle=2/openCV.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "segmentation/" * "CType=2,Nparts=2,RType=3,Reconst=0,UBfactor=10,Vcycle=3/segmentation.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "SLAM_spheric/" * "CType=1,Nparts=2,RType=1,Reconst=1,UBfactor=10,Vcycle=3/SLAM_spheric.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "sparcT1_chip2/" * "CType=1,Nparts=2,RType=3,Reconst=0,UBfactor=10,Vcycle=2/sparcT1_chip2.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "sparcT1_core/" * "CType=3,Nparts=2,RType=3,Reconst=1,UBfactor=10,Vcycle=2/sparcT1_core.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "sparcT2_core/" * "CType=1,Nparts=2,RType=3,Reconst=1,UBfactor=10,Vcycle=2/sparcT2_core.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "stap_qrd/" * "CType=1,Nparts=2,RType=3,Reconst=0,UBfactor=10,Vcycle=1/stap_qrd.hgr.k.2.UBfactor.10.seed.0",
              solutions_path * "stereo_vision/" * "CType=3,Nparts=2,RType=2,Reconst=1,UBfactor=10,Vcycle=3/stereo_vision.hgr.k.2.UBfactor.10.seed.0"]


f = open(result_file, "w")
line  = "design,Nparts,UBfactor,num_cycles,h_threshold,eig_vecs,solver_iters,"
line *= "spec_iters,best_solns,seed,"
line *= "original_cutsize,original_runtime,spectral_cutsize,spectral_runtime,"
line *= "cutsize_improve(%),runtime_overhead(x)\n"
println(f, line)
close(f)


for seed in seed_list
    for Nparts in Nparts_list
        for eig_vecs in eig_vecs_list
            for num_cycles in num_cycles_list
                for h_threshold in h_threshold_list
                    for solver_iters in solver_iters_list
                        for best_solns in best_solns_list
                            for spec_iters in spec_iters_list
                                for UBfactor in UBfactor_list
                                    i = 0
                                    for design in design_list
                                        original_hypergraph_file = benchmark_dir * design * ".hgr"
                                        hypergraph_file = work_dir * design * ".hgr"
                                        cmd = "cp " * original_hypergraph_file * " " * hypergraph_file
                                        run(`sh -c $cmd`, wait=true)
                                        t = 0
                                        #=if partitioner == "hmetis"
                                            cmd = hmetis_exe * " " * hypergraph_file * " " * string(Nparts) * " " * string(UBfactor) * " 10 1 1 0 1 0"
                                            t = @elapsed run(`sh -c $cmd`, wait=true)
                                            ConvertPartitionFileFormat(hypergraph_file * ".part." * string(Nparts))
                                        else
                                            kahypar_ub_factor = UBfactor/50
                                            cmd = kahypar_exe * " -h " * hypergraph_file * " -k " * string(Nparts) * " -e " * string(kahypar_ub_factor) * " -o cut -m recursive -w true -p " * kahypar_config
                                            t = @elapsed run(`sh -c $cmd`, wait=true)
                                            cmd = "mv " * work_dir * "*1.KaHyPar" * " " * hypergraph_file * ".part." * string(Nparts)
                                            run(`sh -c $cmd`, wait=true)
                                        end=#
                                        original_runtime = round(t, digits=2)
                                        original_initial_solution_file = hypergraph_file * ".part." * string(Nparts)
                                        initial_solution_file = hypergraph_file * ".k." * string(Nparts) *  ".UBfactor." * string(UBfactor)
                                        cmd = "mv  " * original_initial_solution_file * " " * initial_solution_file
                                        #run(`sh -c $cmd`, wait=true)
                                        i += 1
                                        t = @elapsed cutsize, hmetis_cut = Main.SpectralRefinement.SpectralHmetisRefinement(hg=hypergraph_file, pfile = partitions[i], Nparts = Nparts, 
                                                            cycles=num_cycles, hyperedges_threshold=h_threshold, ub=UBfactor, nev=eig_vecs, seed=0, solver_iters=solver_iters, refine_iters=spec_iters, best_solns=best_solns);
                                        original_cutsize = hmetis_cut
                                        spectral_runtime = round(t, digits=2)
                                        solution_file = design * ".hgr_" * string(UBfactor) * ".part." * string(Nparts)

                                        println("[INFO]  Design : ",  design, " UBfactor : ", UBfactor, "   Nparts : ", Nparts)
                                        println("[INFO]  Original Summary   CutSize : ", original_cutsize, "    Runtime : ", original_runtime)
                                        println("[INFO]  Spectral Summary   Cutsize : ", cutsize, " Runtime : ", spectral_runtime)

                                        final_solution_file  = work_dir * design * ".hgr.k." * string(Nparts) * ".UBfactor." * string(UBfactor)
                                        final_solution_file *= ".eig_vecs." * string(eig_vecs)
                                        final_solution_file *= ".num_cycles." * string(num_cycles)
                                        final_solution_file *= ".h_threshold." * string(h_threshold)
                                        final_solution_file *= ".solver_iters." * string(solver_iters)
                                        final_solution_file *= ".spec_iters." * string(spec_iters)
                                        final_solution_file *= ".best_solns." * string(best_solns)
                                        final_solution_file *= ".seed." * string(seed)
                                        cmd = "mv " * solution_file * " " * final_solution_file
                                        run(`sh -c $cmd`, wait=true)
                                        cmd = "rm " * hypergraph_file
                                        run(`sh -c $cmd`, wait=true)

                                        cutsize_improve = round((original_cutsize - cutsize) / original_cutsize * 100, digits=2)
                                        runtime_overhead = round(spectral_runtime / original_runtime, digits=2)

                                        line = design * "," * string(Nparts)
                                        line *= "," * string(UBfactor)
                                        line *= "," * string(num_cycles)
                                        line *= "," * string(h_threshold)
                                        line *= "," * string(eig_vecs)
                                        line *= "," * string(solver_iters)
                                        line *= "," * string(spec_iters)
                                        line *= "," * string(best_solns)
                                        line *= "," * string(seed)
                                        line *= "," * string(original_cutsize)
                                        line *= "," * string(original_runtime)
                                        line *= "," * string(cutsize)
                                        line *= "," * string(spectral_runtime)
                                        line *= "," * string(cutsize_improve)
                                        line *= "," * string(runtime_overhead)
                                        line *= "\n"
                                        f = open(result_file, "a")
                                        write(f, line)
                                        close(f)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

close(f)