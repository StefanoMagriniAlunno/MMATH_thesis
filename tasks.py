import os
import sys

from invoke import task  # type: ignore


@task
def directories(c):
    """Create directories"""
    os.path.join(os.getcwd(), "data")
    # os.makedirs(os.path.join(data_dir, 'images'), exist_ok=True)
    # os.makedirs(os.path.join(data_dir, 'audios'), exist_ok=True)
    # os.makedirs(os.path.join(data_dir, 'videos'), exist_ok=True)
    # os.makedirs(os.path.join(data_dir, 'models'), exist_ok=True)
    # os.makedirs(os.path.join(data_dir, 'repo'), exist_ok=True)
    # os.makedirs(os.path.join(data_dir, "db"), exist_ok=True)


@task
def build(c, PY: str, CC: str, CXX: str, CU: str):
    """Build packages"""
    c.run(r"mkdir -p source/.cache")
    c.run(f"make -C source {PY=} {CC=} {CXX=} {CU=} > temp/build.log 2>&1")
    c.run(r"cp source/.cache/* .venv/lib/python3.10/site-packages")


@task
def install(c):
    """Install packages for development"""
    list_packages = [
        "pillow imageio",
        "numpy scipy pandas scikit-learn",  # scientific computing
        "matplotlib seaborn plotly",  # plotting
        "tqdm colorama",  # utilities
        "torch torchvision torchaudio",  # gpu computing
        "pycuda",  # gpu computing
    ]

    c.run(f"{sys.executable} -m pip install {' '.join(list_packages)}")


@task
def download(c):
    """Download datasets in data/"""
