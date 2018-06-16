FROM jupyter/datascience-notebook

#from https://github.com/mjbright/jupyter_trusted_builds/blob/master/demo/Dockerfile

# Upgrade OS and install a couple of packages
USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libreadline-dev nano xvfb libfontconfig wkhtmltopdf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


#Hack wkhtmltopdf to uses xvfb
RUN mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf2 && echo -e '#!/bin/bash\nxvfb-run wkhtmltopdf2 "$@"' > /usr/bin/wkhtmltopdf && chmod 755 /usr/bin/wkhtmltopdf


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


# Install bash_kernel:
RUN pip install --no-cache-dir bash_kernel


# Install list of dependencies from INF-618: Tensorflow, keras, etc
RUN pip install --no-cache-dir -U  scipy ipykernel jupyter matplotlib h5py pydot-ng graphviz sklearn scikit-image np_utils opencv-contrib-python tensorflow keras Tensorboard


# Install RISE (LIVE Reveal) extension:
RUN conda install --quiet --yes -c damianavila82 rise


# Install Jessica Hamrick's PlotChecker module:
RUN pip install plotchecker


# Install MPDL3 library:
RUN pip install mpld3


# Install hide_code extension:
#user root
#RUN pip install hide_code && \
#    jupyter nbextension install --py hide_code && \
#    jupyter nbextension enable --py hide_code && \
#    jupyter serverextension enable --py hide_code


# Install Scisheets Widget
user jovyan
RUN \
    git clone https://github.com/paulo-raca/jupyter_scisheets_widget.git && \
    cd jupyter_scisheets_widget && \
    python setup.py build && \
    pip install -e . && \
    jupyter nbextension install --py --symlink --sys-prefix jupyter_scisheets_widget && \
    jupyter nbextension enable --py --sys-prefix jupyter_scisheets_widget

