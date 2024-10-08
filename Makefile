.PHONY=tmux nvim_appimage nvim_tar nvim_src nvim_user cmake carapace cp-gitconfig

ifeq ($(strip $(shell uname -a | grep aarch64)),)
	ARCH:=x86_64
else
	ARCH:=aarch64
endif

SHELL_RC:=${HOME}/.zshrc

all: cargo_tools_install cp-gitconfig

nvim_appimage: 
	rm -rf ~/local/bin/nvim* && \
	wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -O ~/local/bin/nvim.appimage && \
	chmod +x ${HOME}/local/bin/nvim.appimage && \
	ln -s ${HOME}/local/bin/nvim.appimage ${HOME}/local/bin/nvim
ifeq ($(strip $(shell grep "alias vi=nvim.appimage" ${SHELL_RC})),)
	echo 'alias vi=nvim.appimage' >> ${SHELL_RC}
endif

nvim_tar: 
	rm -rf ~/local/nvim-linux64 && \
	wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz && \
	tar -C ~/local -xzvf nvim-linux64.tar.gz && \
	rm -rf nvim-linux64.tar.gz
	${MAKE} nvim_rc

nvim_src: nvim_rc
	wget https://github.com/neovim/neovim/archive/refs/tags/stable.tar.gz && \
	tar xvf stable.tar.gz && \
	cd neovim-stable && \
	make CMAKE_BUILD_TYPE=Release && \
	make CMAKE_INSTALL_PREFIX=${HOME}/local/nvim-linux64 install && \
	cd .. && rm -rf stable.tar.gz* neovim-stable && \
	${MAKE} nvim_rc

nvim_user:
	rm -rf ${HOME}/.config/nvim && \
	git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim && \
	rm -rf ~/.config/nvim/lua/user && \
	mkdir -p ~/.config/nvim/lua/user && \
	cp nvim/init.lua ~/.config/nvim/lua/user/init.lua && \
	nvim "+LspInstall c++ python rust" && nvim "+TSInstall cpp python rust"

cmake_bin:
	wget -O cmake.tar.gz https://github.com/Kitware/CMake/releases/download/v3.25.0/cmake-3.25.0-linux-${ARCH}.tar.gz && \
	rm -rf ${HOME}/local/cmake && mkdir ${HOME}/local/cmake && \
	tar --strip-components 1 -C ~/local/cmake -xvf cmake.tar.gz && \
	rm -rf cmake.tar.gz 
ifeq ($(strip $(shell grep '$${HOME}/local/cmake/bin' ${SHELL_RC})),)
	echo 'export PATH=$${HOME}/local/cmake/bin:$${PATH}' >> ${SHELL_RC}
endif

miniconda3:
	[ ! -d "${HOME}/miniconda3" ] && \
	mkdir -p ${HOME}/miniconda3 && \
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${HOME}/miniconda3/miniconda.sh && \
	bash ${HOME}/miniconda3/miniconda.sh -b -u -p ${HOME}/miniconda3 && \
	rm -rf ${HOME}/miniconda3/miniconda.sh && \
	${HOME}/miniconda3/bin/conda init zsh

cuda:
	wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin && \
	sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
	wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda-repo-ubuntu2204-12-1-local_12.1.1-530.30.02-1_amd64.deb && \
	sudo dpkg -i cuda-repo-ubuntu2204-12-1-local_12.1.1-530.30.02-1_amd64.deb && \
	sudo cp /var/cuda-repo-ubuntu2204-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
	sudo apt-get update && \
	sudo apt-get -y install cuda

docker_cuda_toolkit:
	curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  	&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list && \
	sudo apt-get update && \
	sudo apt-get install -y nvidia-container-toolkit

pytorch_12_1:
	conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia

aws: shell_rc
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
	unzip awscliv2.zip && \
	sudo ./aws/install --bin-dir ${HOME}/local/bin --install-dir ${HOME}/local/aws-cli --update && \
	rm -rf aws awscliv2.zip*

carapace:
ifeq ($(strip $(shell grep "export CARAPACE_BRIDGES" ${SHELL_RC})),)
	wget "https://github.com/carapace-sh/carapace-bin/releases/latest/download/carapace-bin_linux_amd64.tar.gz" -O "carapace-bin_linux_amd64.tar.gz" && \
	tar -C ~/local/bin -xvf carapace-bin_linux_amd64.tar.gz && \
	rm -rf carapace-bin_linux_amd64.tar.gz && \
    cat carapace.txt >> ${SHELL_RC}
endif

zsh:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

nvim_rc:
ifeq ($(strip $(shell grep '$${HOME}/local/nvim-linux64/bin' ${SHELL_RC})),)
	echo 'export PATH=$${HOME}/local/nvim-linux64/bin:$${PATH}' >> ${SHELL_RC}
endif
ifeq ($(strip $(shell grep "alias vi=nvim" ${SHELL_RC})),)
	echo 'alias vi=nvim' >> ${SHELL_RC}
endif

shell_rc:
ifeq ($(strip $(shell grep '$${HOME}/local/bin' ${SHELL_RC})),)
	echo 'export PATH=$${HOME}/local/bin:$${PATH}' >> ${SHELL_RC}
endif

rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
ifeq ($(strip $(shell grep '$${HOME}/.cargo/bin' ${SHELL_RC})),)
	echo 'export PATH=$${HOME}/.cargo/bin:$${PATH}' >> ${SHELL_RC}
	export PATH=${HOME}/.cargo/bin:${PATH}
endif

CARGO_TOOLS := ripgrep sd lsd watchexec-cli bat zoxide fd-find zellij git-delta

cargo_tools: rust
	cargo install cargo-binstall && \
	cargo binstall --no-confirm --no-symlinks --force ${CARGO_TOOLS} && \
	${MAKE} cargo_tools_common

cargo_tools_install: rust
	cargo install --bins --force --locked ${CARGO_TOOLS} && \
	${MAKE} cargo_tools_common

zenith:
	cargo install --features nvidia --git https://github.com/bvaisvil/zenith.git

cp-gitconfig:
	if [ ! -f "${HOME}/.gitconfig" ]; then cp gitconfig ${HOME}/.gitconfig; fi

cargo_tools_common:
	mkdir -p ${HOME}/.config && \
	rm -rf ${HOME}/.config/zellij && \
	cp -r zellij ${HOME}/.config/
ifeq (,$(wildcard ${HOME}/.fzf))
	git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf && ${HOME}/.fzf/install --all
else
	cd ${HOME}/.fzf && git pull && ./install --all
endif

ifeq ($(strip $(shell grep "source \$${HOME}/.cargo/env" ${SHELL_RC})),)
	echo 'source $${HOME}/.cargo/env' >> ${SHELL_RC}
endif
ifeq ($(strip $(shell grep "alias ls=lsd" ${SHELL_RC})),)
	echo 'alias ls=lsd' >> ${SHELL_RC}
	echo 'alias cd=z' >> ${SHELL_RC}
	echo 'eval "$$(zoxide init zsh)"' >> ${SHELL_RC}
	echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' >> ${SHELL_RC}
	echo 'export FZF_DEFAULT_COMMAND="fd --type f"' >> ${SHELL_RC}
	echo 'export FZF_DEFAULT_OPTS="--ansi"' >> ${SHELL_RC}
endif


