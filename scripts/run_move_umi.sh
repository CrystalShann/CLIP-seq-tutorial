#!/bin/bash
#SBATCH --job-name=umi_moving_job           # Updated Job name (change as needed)
#SBATCH --output=umi_moving_%j.log          # Output log file
#SBATCH --error=umi_moving_%j.err           # Error log file
#SBATCH --ntasks=8                         # Number of tasks (CPU cores)
#SBATCH --mem-per-cpu=8G                    # Memory allocation per CPU (total: 32G in this case)
#SBATCH --time=12:00:00                     # Maximum runtime (12 hours)

# Load required Python module
module load python/3.11
 
# Run the Python script
python move_umi.py
