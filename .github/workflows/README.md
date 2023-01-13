# Tarantool docs workflows

These GitHub workflows automate the deployment of Tarantool CE documentation
to development and production servers.

## Deploy a development branch to dev

**Workflow file**: [deploy-branch.yml](https://github.com/tarantool/doc/blob/latest/.github/workflows/deploy-branch.yml)

**Description**: a commonly used workflow for documentation development.
Used for viewing and sharing doc changes before publishing.

**When**: when a PR is created or updated.

> Note: if a new commit is added to a PR shortly after the workflow is started, the workflow run
> will be cancelled and restarted with all newly added changes.

**Details**:

* The resulting Sphinx target is JSON.
* Once the docs are built as JSON files, they are uploaded to the MCS S3 cloud storage: `tarantool.io`
  bucket, a folder named after the branch.
* The deployment URL is `https://docs.d.tarantool.io/en/doc/<BRANCH_NAME>/`
* It takes about 2 minutes to deploy all changes to the dev website after the worklow is completed.
  If you don't see the latest changes, check again in 1-2 minutes. 
* `make json` step (building docs with Sphinx) allows warnings in the doc build to avoid breaking
  the whole docs workflow because of the changes in submodules (we don't manage nor test them). 
* [Tarantool docs CI/CD reports](https://u.internal.myteam.mail.ru/profile/tt_docs_cicd_reports) channel
  in VK Teams informs about deployment issues.

## Deploy the `latest` branch to prod

**Workflow file**: [main.yml](https://github.com/tarantool/doc/blob/latest/.github/workflows/main.yml)

**Description**: deploys the `latest` branch to production.

**When**:
  * when a new commit is pushed to `latest`
  * once a day (by cron).

## Destroy a development branch deployment

**Workflow file**: [destroy-deployment.yml](https://github.com/tarantool/doc/blob/latest/.github/workflows/destroy-deployment.yml)

**Description**: removes branch deployments that aren't used after the branch in merged.

**When**: when a PR is merged.

## Deploy a submodule branch

**Workflow file**: [deploy-custom.yml](https://github.com/tarantool/doc/blob/latest/.github/workflows/deploy-custom.yml)

**Description**: deploys docs to dev using the specified branches of submodules.
Used for viewing and sharing submodule doc changes before publishing.

**When**: run manually when after making changes in a submodule branch

**How to run**:
1. Go to **Actions** > **Custom-deploy-branch** and click **Run workflow**.
2. Provide a unique name for the deployment. This name will be used in its URL:
  `https://docs.d.tarantool.io/en/doc/<DEPLOYMENT_NAME>/`
3. Specify the submodule branch or commit in the corresponding field.
4. Click **Run workflow**.
