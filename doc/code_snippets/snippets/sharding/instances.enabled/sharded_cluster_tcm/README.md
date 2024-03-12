# Sharded cluster with CRUD: Docker

## Running

1. Run Docker.

2. Copy the SDK archive (`tarantool-enterprise-sdk-<version>.tar.gz`) to the `sdk` folder next to `Dockerfile`.

3. (Optional) If you use macOS aarch64, set the platform:

   ```shell
   $ export DOCKER_DEFAULT_PLATFORM=linux/amd64
   ```

4. Build the image:

   ```shell
   $ docker build -t my-application .
   ```

5. Execute `docker compose up`:

   ```shell
   $ docker compose up
   ```
   
   Wait until the cluster is run:

   ```shell
   tarantool-1  |    • Application was successfully built
   tarantool-1  |    • Starting an instance [sharded_cluster_tcm:storage-a-002]...
   tarantool-1  |    • Starting an instance [sharded_cluster_tcm:storage-b-001]...
   tarantool-1  |    • Starting an instance [sharded_cluster_tcm:storage-b-002]...
   tarantool-1  |    • Starting an instance [sharded_cluster_tcm:router-a-001]...
   tarantool-1  |    • Starting an instance [sharded_cluster_tcm:storage-a-001]...
   ```

## TCM

1. Open http://0.0.0.0:8080/.

2. Log in using generated credentials, for example:

   ```shell
   WRN Generated super admin credentials login=admin password=tF1FAurUm5mQhsrmaeHNDUIb0LKvZQAv
   ...

3. Open the router's console and perform the initial cluster bootstrap:

   ```shell
   sharded_cluster_crud:router-a-001> vshard.router.bootstrap()
   ---
   - true
   ...
   ```

4. To insert sample data, call `crud.insert_many()` on the router:

   ```lua
   crud.insert_many('bands', {
       { 1, box.NULL, 'Roxette', 1986 },
       { 2, box.NULL, 'Scorpions', 1965 },
       { 3, box.NULL, 'Ace of Base', 1987 },
       { 4, box.NULL, 'The Beatles', 1960 },
       { 5, box.NULL, 'Pink Floyd', 1965 },
       { 6, box.NULL, 'The Rolling Stones', 1962 },
       { 7, box.NULL, 'The Doors', 1965 },
       { 8, box.NULL, 'Nirvana', 1987 },
       { 9, box.NULL, 'Led Zeppelin', 1968 },
       { 10, box.NULL, 'Queen', 1970 }
   })
   ```
