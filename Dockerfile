FROM python:3.12

ENV QE_TOOLS_DIR=/qe-tools

RUN apt-get update \
  && apt-get install -y ssh gnupg software-properties-common curl gpg vim --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install the Rosa CLI
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz --output /tmp/rosa-linux.tar.gz \
  && tar xvf /tmp/rosa-linux.tar.gz --no-same-owner \
  && mv rosa /usr/bin/rosa \
  && chmod +x /usr/bin/rosa \
  && rosa version

# Install the OpenShift/Kubernetes CLI (oc/kubectl)
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz --output /tmp/openshift-client-linux.tar.gz \
  && tar xvf /tmp/openshift-client-linux.tar.gz --no-same-owner \
  && mv oc /usr/bin/oc \
  && mv kubectl /usr/bin/kubectl \
  && chmod +x /usr/bin/oc \
  && chmod +x /usr/bin/kubectl

# Install the Advanced cluster management CLI (cm)
RUN curl -s https://api.github.com/repos/stolostron/cm-cli/releases/latest \
  | grep "browser_download_url.*linux_amd64.tar.gz" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | xargs curl -L --output /tmp/cm_linux_amd64.tar.gz \
  && tar xvf /tmp/cm_linux_amd64.tar.gz --no-same-owner \
  && mv cm /usr/bin/cm

# Install regctl
RUN curl -L https://github.com/regclient/regclient/releases/latest/download/regctl-linux-amd64 --output /usr/bin/regctl \
  && chmod +x /usr/bin/regctl

RUN python3 -m pip install --no-cache pip poetry --upgrade \
  && poetry config virtualenvs.in-project true \
  && poetry config installer.max-workers 10

WORKDIR $QE_TOOLS_DIR
COPY pyproject.toml poetry.lock ${QE_TOOLS_DIR}/
RUN poetry config cache-dir ${QE_TOOLS_DIR} \
  && poetry install
