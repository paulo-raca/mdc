FROM jupyter/datascience-notebook

#from https://github.com/mjbright/jupyter_trusted_builds/blob/master/demo/Dockerfile

# Upgrade OS
USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Install libreadline-dev, which is necessary for some of the dependencies
RUN apt-get update && \
    apt-get install -y libreadline-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Alow sudo without password
RUN echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# Upgrade pip
USER jovyan
RUN pip install --no-cache-dir -U $(pip freeze | cut -d"=" -f1)


# Upgrade conda
RUN conda update --quiet --yes --all && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


# Install Tensorflow
RUN conda update --quiet --yes --all && \
    conda install --quiet --yes \
    'tensorflow' \
    'keras' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


# Install RISE (LIVE Reveal) extension:
RUN conda install --quiet --yes -c damianavila82 rise


# Install Jessica Hamrick's PlotChecker module:
RUN pip install plotchecker


# Install MPDL3 library:
RUN pip install mpld3


# Install hide_code extension:
USER root
RUN pip install hide_code && \
    jupyter nbextension install --py hide_code && \
    jupyter nbextension enable --py hide_code && \
    jupyter serverextension enable --py hide_code && \
    apt-get update && \
    apt-get install -y xvfb libfontconfig wkhtmltopdf && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf2
COPY wkhtmltopdf /usr/bin/



# Install bash_kernel:
# USER jovyan
# RUN pip install --no-cache-dir bash_kernel && \
#     python -m bash_kernel.install
