<p align="center">
  <img src="https://raw.githubusercontent.com/PKief/vscode-material-icon-theme/ec559a9f6bfd399b82bb44393651661b08aaf7ba/icons/folder-markdown-open.svg" width="100" />
</p>
<p align="center">
    <h1 align="center">K8S</h1>
</p>
<p align="center">
    <em><code>► INSERT-TEXT-HERE</code></em>
</p>
<p align="center">
	<!-- local repository, no metadata badges. -->
<p>
<p align="center">
		<em>Developed with the software and tools below.</em>
</p>
<p align="center">
	<img src="https://img.shields.io/badge/GNU%20Bash-4EAA25.svg?style=flat&logo=GNU-Bash&logoColor=white" alt="GNU%20Bash">
</p>
<hr>

##  Quick Links

> - [ Overview](#-overview)
> - [ Features](#-features)
> - [ Repository Structure](#-repository-structure)
> - [ Modules](#-modules)
> - [ Getting Started](#-getting-started)
>   - [ Installation](#-installation)
>   - [Running k8s](#-running-k8s)
>   - [ Tests](#-tests)
> - [ Project Roadmap](#-project-roadmap)
> - [ Contributing](#-contributing)
> - [ License](#-license)
> - [ Acknowledgments](#-acknowledgments)

---

##  Overview

<code>► INSERT-TEXT-HERE</code>

---

##  Features

<code>► INSERT-TEXT-HERE</code>

---

##  Repository Structure

```sh
└── k8s/
    ├── CKA
    │   ├── K8supgrade.txt
    │   ├── Sep23-examdayfeedback.txt
    │   ├── etcd-multicluster.txt
    │   └── my-cka-exam-prep.md
    ├── LICENSE
    ├── README.md
    ├── Vagrantfile
    ├── allthescriptsforkubernetesthehardway.sh
    ├── checkservicestatus.sh
    ├── kk-gcp-playgroundsetup
    │   ├── README.md
    │   ├── create_cluster_in_gcp.sh
    │   └── delete_cluster.sh
    └── ubuntu
        ├── allow-bridge-nf-traffic.sh
        ├── cert_verify.sh
        ├── install-docker-2.sh
        ├── install-docker.sh
        ├── update-dns.sh
        └── vagrant
            ├── install-guest-additions.sh
            └── setup-hosts.sh
```

---

##  Modules

<details closed><summary>.</summary>

| File                                                                               | Summary                         |
| ---                                                                                | ---                             |
| [Vagrantfile](Vagrantfile)                                                         | <code>► INSERT-TEXT-HERE</code> |
| [checkservicestatus.sh](checkservicestatus.sh)                                     | <code>► INSERT-TEXT-HERE</code> |
| [allthescriptsforkubernetesthehardway.sh](allthescriptsforkubernetesthehardway.sh) | <code>► INSERT-TEXT-HERE</code> |

</details>

<details closed><summary>CKA</summary>

| File                                                       | Summary                         |
| ---                                                        | ---                             |
| [K8supgrade.txt](CKA/K8supgrade.txt)                       | <code>► INSERT-TEXT-HERE</code> |
| [Sep23-examdayfeedback.txt](CKA/Sep23-examdayfeedback.txt) | <code>► INSERT-TEXT-HERE</code> |
| [etcd-multicluster.txt](CKA/etcd-multicluster.txt)         | <code>► INSERT-TEXT-HERE</code> |

</details>

<details closed><summary>kk-gcp-playgroundsetup</summary>

| File                                                                        | Summary                         |
| ---                                                                         | ---                             |
| [delete_cluster.sh](kk-gcp-playgroundsetup/delete_cluster.sh)               | <code>► INSERT-TEXT-HERE</code> |
| [create_cluster_in_gcp.sh](kk-gcp-playgroundsetup/create_cluster_in_gcp.sh) | <code>► INSERT-TEXT-HERE</code> |

</details>

<details closed><summary>ubuntu</summary>

| File                                                            | Summary                         |
| ---                                                             | ---                             |
| [cert_verify.sh](ubuntu/cert_verify.sh)                         | <code>► INSERT-TEXT-HERE</code> |
| [allow-bridge-nf-traffic.sh](ubuntu/allow-bridge-nf-traffic.sh) | <code>► INSERT-TEXT-HERE</code> |
| [update-dns.sh](ubuntu/update-dns.sh)                           | <code>► INSERT-TEXT-HERE</code> |
| [install-docker.sh](ubuntu/install-docker.sh)                   | <code>► INSERT-TEXT-HERE</code> |
| [install-docker-2.sh](ubuntu/install-docker-2.sh)               | <code>► INSERT-TEXT-HERE</code> |

</details>

<details closed><summary>ubuntu.vagrant</summary>

| File                                                                    | Summary                         |
| ---                                                                     | ---                             |
| [setup-hosts.sh](ubuntu/vagrant/setup-hosts.sh)                         | <code>► INSERT-TEXT-HERE</code> |
| [install-guest-additions.sh](ubuntu/vagrant/install-guest-additions.sh) | <code>► INSERT-TEXT-HERE</code> |

</details>

---

##  Getting Started

***Requirements***

Ensure you have the following dependencies installed on your system:

* **Shell**: `version x.y.z`

###  Installation

1. Clone the k8s repository:

```sh
git clone ../k8s
```

2. Change to the project directory:

```sh
cd k8s
```

3. Install the dependencies:

```sh
chmod +x main.sh
```

###  Running `k8s`

Use the following command to run k8s:

```sh
./main.sh
```

###  Tests

Use the following command to run tests:

```sh
bats *.bats
```

---

##  Project Roadmap

- [X] `► INSERT-TASK-1`
- [ ] `► INSERT-TASK-2`
- [ ] `► ...`

---

##  Contributing

Contributions are welcome! Here are several ways you can contribute:

- **[Submit Pull Requests](https://local/k8s/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.
- **[Join the Discussions](https://local/k8s/discussions)**: Share your insights, provide feedback, or ask questions.
- **[Report Issues](https://local/k8s/issues)**: Submit bugs found or log feature requests for the `k8s` project.

<details closed>
    <summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your local account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone ../k8s
   ```
3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.
   ```sh
   git checkout -b new-feature-x
   ```
4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.
   ```sh
   git commit -m 'Implemented new feature x.'
   ```
6. **Push to GitHub**: Push the changes to your forked repository.
   ```sh
   git push origin new-feature-x
   ```
7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.

Once your PR is reviewed and approved, it will be merged into the main branch.

</details>

---

##  License

This project is protected under the [SELECT-A-LICENSE](https://choosealicense.com/licenses) License. For more details, refer to the [LICENSE](https://choosealicense.com/licenses/) file.

---

##  Acknowledgments

- List any resources, contributors, inspiration, etc. here.

[**Return**](#-quick-links)

---
