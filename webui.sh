#!/bin/bash -i
# This file is part of stable-diffusion-webui (https://github.com/sd-webui/stable-diffusion-webui/).

# Copyright 2022 sd-webui team.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>. 
# Start the Stable Diffusion WebUI for Linux Users

DIRECTORY="."
ENV_FILE="environment.yaml"
ENV_NAME="ldm"
ENV_MODIFIED=$(date -r $ENV_FILE "+%s")
ENV_MODIFED_FILE=".env_updated"
ENV_UPDATED=0

# Models used for upscaling
GFPGAN_MODEL="https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth"
LATENT_DIFFUSION_REPO="https://github.com/devilismyfriend/latent-diffusion.git"
LSDR_CONFIG="https://heibox.uni-heidelberg.de/f/31a76b13ea27482981b4/?dl=1"
LSDR_MODEL="https://heibox.uni-heidelberg.de/f/578df07c8fc04ffbadf3/?dl=1"
REALESRGAN_MODEL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth"
REALESRGAN_ANIME_MODEL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth"
SD_CONCEPT_REPO="https://github.com/sd-webui/sd-concepts-library/archive/refs/heads/main.zip"


if [[ -f $ENV_MODIFED_FILE ]]; then 
    ENV_MODIFIED_CACHED=$(<${ENV_MODIFED_FILE})
else 
    ENV_MODIFIED_CACHED=0
fi

# Check to see if the SD model already exists, if not then it creates it and prompts the user to add the SD AI models to the repo directory
sd_model_loading () {
    if [ -f "$DIRECTORY/models/ldm/stable-diffusion-v1/model.ckpt" ]; then
        printf "AI Model already in place. Continuing...\n\n"
    else
        printf "\n\n########## MOVE MODEL FILE ##########\n\n"
        printf "Please download the 1.4 AI Model from Huggingface (or another source) and place it inside of the stable-diffusion-webui folder\n\n"
        read -p "Once you have sd-v1-4.ckpt in the project root, Press Enter...\n\n"
        
        # Check to make sure checksum of models is the original one from HuggingFace and not a fake model set
        printf "fe4efff1e174c627256e44ec2991ba279b3816e364b49f9be2abc0b3ff3f8556 sd-v1-4.ckpt" | sha256sum --check || exit 1
        mv sd-v1-4.ckpt $DIRECTORY/models/ldm/stable-diffusion-v1/model.ckpt
        rm -r ./Models
    fi
}

# Checks to see if the upscaling models exist in their correct locations. If they do not they will be downloaded as required
post_processor_model_loading () {
    # Check to see if GFPGAN has been added yet, if not it will download it and place it in the proper directory
    if [ -f "$DIRECTORY/models/gfpgan/GFPGANv1.3.pth" ]; then
        printf "GFPGAN already exists. Continuing...\n\n"
    else
        printf "Downloading GFPGAN model. Please wait...\n"
        wget $GFPGAN_MODEL -P $DIRECTORY/models/gfpgan
    fi

    # Check to see if realESRGAN has been added yet, if not it will download it and place it in the proper directory
    if [ -f "$DIRECTORY/models/realesrgan/RealESRGAN_x4plus.pth" ]; then
        printf "realESRGAN already exists. Continuing...\n\n"
    else
        printf "Downloading realESRGAN model. Please wait...\n"
        wget $REALESRGAN_MODEL -P $DIRECTORY/models/realesrgan
        wget $REALESRGAN_ANIME_MODEL -P $DIRECTORY/models/realesrgan
    fi

    # Check to see if LDSR has been added yet, if not it will be cloned and its models downloaded to the correct directory
    if [ -f "$DIRECTORY/models/ldsr/model.ckpt" ]; then
        printf "LDSR already exists. Continuing...\n\n"
    else
        printf "Cloning LDSR and downloading model. Please wait...\n"
        git clone $LATENT_DIFFUSION_REPO
        mv latent-diffusion $DIRECTORY/models/ldsr
        mkdir $DIRECTORY/models/ldsr/experiments
        mkdir $DIRECTORY/models/ldsr
        wget $LSDR_CONFIG -P $DIRECTORY/models/ldsr
        mv $DIRECTORY/models/ldsr/index.html?dl=1 $DIRECTORY/models/ldsr/project.yaml
        wget $LSDR_MODEL -P $DIRECTORY/models/ldsr
        mv $DIRECTORY/models/ldsr/index.html?dl=1 $DIRECTORY/models/ldsr/model.ckpt
    fi

    # Check to see if SD Concepts has been added yet, if not it will download it and place it in the proper directory
    if [ -d "$DIRECTORY/models/custom/sd-concepts-library" ]; then
        printf "SD Concepts Library already exists. Continuing...\n\n"
    else
        printf "Downloading and Extracting SD Concepts Library model. Please wait...\n"
        mkdir $DIRECTORY/models/custom
        wget $SD_CONCEPT_REPO
        if ! command -v unzip &> /dev/null
        then
            printf "Warning: unzip could not be found. \nPlease install 'unzip' from your package manager and rerun this program.\n"
            exit 1
        fi
        unzip main.zip
        mv sd-concepts-library-main/sd-concepts-library $DIRECTORY/models/custom
    fi
}

# Function to initialize the other functions
start_initialization () {
    virtualenv venv
    sd_model_loading
    post_processor_model_loading
    source venv/bin/activate
    pip3 install --upgrade pip
    pip3 install numpy scikit-image
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116
    pip3 install -r requirements.txt
    if [ ! -e "models/ldm/stable-diffusion-v1/model.ckpt" ]; then
        echo "Your model file does not exist! Place it in 'models/ldm/stable-diffusion-v1' with the name 'model.ckpt'."
        exit 1
    fi
    CUDA_VISIBLE_DEVICES=2 streamlit run --server.address 0.0.0.0 --server.port 31712 scripts/webui_streamlit.py
}

start_initialization "$@"