#!/bin/bash

# Params
config_file="config.ini"
logfile="temp/installation.log"
venv=".venv"
venv_pip_version="24.2"
sphinx_config_dir="docs/source"

# Read inputs
if [ -f "$config_file" ]; then
    python3_executable=$(grep "python" "$config_file" | cut -d'=' -f2)
    gcc_executable=$(grep "gcc" "$config_file" | cut -d'=' -f2)
    gxx_executable=$(grep "g++" "$config_file" | cut -d'=' -f2)
    nvcc_executable=$(grep "nvcc" "$config_file" | cut -d'=' -f2)
else
    echo -e "\e[31mERROR\e[0m Config file $config_file not found"
    exit 1
fi

# controllo se python3_executable è effettivamente un eseguibile di python3
if ! [ -x "$(command -v "$python3_executable")" ]; then
    echo -e "\e[31mERROR\e[0m $python3_executable is not an executable"
    exit 1
fi

# Make log file
mkdir -p temp
true > "$logfile"

# System prerequisites
echo -e "\e[33mChecking prerequisites...\e[0m"
if ! scripts/check_prerequisites.sh "$python3_executable"; then
    echo -e "\e[31mERROR\e[0m Prerequisites check failed"
    exit 1
fi
echo -e "\e[32mSUCCESS\e[0m Prerequisites check completed"

# Make the environment with virtualenv
echo -e "\e[33mCreating virtual environment...\e[0m"
if ! "$python3_executable" -m virtualenv "$venv" --no-download --always-copy --prompt="MMATH_thesis" >> "$logfile" 2>&1; then
    echo -e "\e[31mERROR\e[0m Failed to create virtual environment or save logs"
    exit 1
fi
echo -e "\e[32mSUCCESS\e[0m Virtual environment created"

# New params
python3_cmd="$(pwd)/$venv/bin/python3"
pre_commit_cmd="$(pwd)/$venv/bin/pre-commit"
invoke_cmd="$(pwd)/$venv/bin/invoke"
sphinx_cmd="$(pwd)/$venv/bin/sphinx-build"

# Install packages for the virtual environment
echo -e "\e[33mPreparing virtual environment...\e[0m"
echo "pip upgrade..."
if ! "$python3_cmd" -m pip install --upgrade pip=="$venv_pip_version" >> "$logfile" 2>&1; then
    echo -e "\e[31mERROR\e[0m Failed to upgrade pip"
    "$python3_cmd" assets/error.py
    exit 1
fi
echo "install requirements.txt..."
if ! "$python3_cmd" -m pip install -r requirements.txt >> "$logfile" 2>&1; then
    echo -e "\e[31mERROR\e[0m Failed to install packages"
    "$python3_cmd" assets/error.py
    exit 1
fi
echo "invoke install..."
if ! "$invoke_cmd" install >> "$logfile" 2>&1; then
    echo -e "\e[31mERROR\e[0m Failed to install packages"
    "$python3_cmd" assets/error.py
    exit 1
fi
echo "invoke build..."
if ! "$invoke_cmd" build --PY "$python3_executable" --CC "$gcc_executable" --CXX "$gxx_executable" --CU "$nvcc_executable" >> "$logfile" 2>&1; then
    echo -e "\e[31mERROR\e[0m Failed to build packages"
    exit 1
fi
echo -e "\e[32mSUCCESS\e[0m Virtual environment prepared"

# Prepare repository
echo -e "\e[33mPreparing repository...\e[0m"
echo "pre-commit install..."
if ! "$pre_commit_cmd" install >> "$logfile" 2>&1; then
    echo -e "\e[31mERROR\e[0m Failed to install pre-commit"
    "$python3_cmd" assets/error.py
    exit 1
fi
echo "pre-commit install-hooks..."
if ! "$pre_commit_cmd" install-hooks >> "$logfile" 2>&1; then
    echo -e "\e[31mERROR\e[0m Failed to install pre-commit hooks"
    "$python3_cmd" assets/error.py
    exit 1
fi
echo "sphinx build..."
bash scripts/make_docs.sh "$logfile" "$python3_cmd" "$sphinx_cmd" "$sphinx_config_dir"
echo "create data directory..."
mkdir -p data
echo "invoke directories..."
if ! "$invoke_cmd" directories >> "$logfile" 2>&1; then
    echo -e "\e[31mERROR\e[0m Failed to create directories"
    exit 1
fi
echo "invoke download..."
if ! "$invoke_cmd" download >> "$logfile" 2>&1; then
    echo -e "\e[31mERROR\e[0m Failed to download data"
    exit 1
fi
echo -e "\e[32mSUCCESS\e[0m Repository prepared"

# Done
$python3_cmd assets/done.py

echo ""
echo "Please activate the virtual environment with the following command:"
echo "$ source $venv/bin/activate"
echo ""

# Last operations...
mkdir -p logs
mkdir -p tools
