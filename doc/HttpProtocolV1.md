# HTTP Protocol (version 1) <br> Jobs Microservice

Jobs microservice implements a HTTP compatible API, that can be accessed on configured port.
All input and output data is serialized in JSON format. Errors are returned in [standard format]().

* [POST /v1/jobs/add_job](#operation1)
* [POST /v1/jobs/add_uniq_job](#operation2)
* [POST /v1/jobs/get_jobs](#operation3)
* [POST /v1/jobs/get_job_by_id](#operation4)
* [POST /v1/jobs/start_job_by_id](#operation5)
* [POST /v1/jobs/start_job_by_type](#operation6)
* [POST /v1/jobs/extend_job](#operation7)
* [POST /v1/jobs/abort_job](#operation8)
* [POST /v1/jobs/complete_job](#operation9)
* [POST /v1/jobs/delete_job_by_id](#operation10)
* [POST /v1/jobs/delete_jobs](#operation11)

## Operations

### <a name="operation1"></a> Method: 'POST', route '/v1/jobs/add_job'

Add new job

**Request body:** 
- new_job: NewJobV1 - params for creates new job

**Response body:**
job: JobV1 - generated new job

### <a name="operation2"></a> Method: 'POST', route '/v1/jobs/add_uniq_job'

Add new job if not exist with same type and ref_id

**Request body:** 
- new_job: NewJobV1 - params for creates new job

**Response body:**
- job: JobV1 - retrived existing or generated new job

### <a name="operation3"></a> Method: 'POST', route '/v1/jobs/get_jobs'

Get jobs by filter

**Request body:**
- filter: Object
    - id: string - (optional) unique job id
    - type: string - (optional) job type
    - ref_id: string - (optional) job reference object id
    - created: Date - (optional) created object timestamp 
    - created_from: Date - (optional) create object timestamp from interval
    - created_to: Date - (optional) create object timestamp to interval
    - started: Date - (optional) started object timestamp 
    - started_from: Date - (optional) started object timestamp from interval
    - started_to: Date - (optional) started object timestamp to interval
    - locked_until:Date - (optional) locked until object timestamp 
    - locked_from: Date - (optional) locked until object timestamp from interval
    - locked_to: Date - (optional) locked until object timestamp to interval
    - execute_until: Date - (optional) execute until object timestamp
    - execute_from: Date - (optional) execute until object timestamp from interval
    - execute_to: Date - (optional) execute until object timestamp to interval
    - completed: Date - (optional) completed object timestamp
    - completed_from: Date - (optional) completed object timestamp from interval
    - completed_to: Date - (optional) completed object timestamp to interval
    - retries: number - number of retries count
    - min_retries: number - minimum retries count (return all jobs where retries <= min_retires )
- paging: Object
  - skip: int - (optional) start of page (default: 0). Operation returns paged result
  - take: int - (optional) page length (max: 100). Operation returns paged result

**Response body:**
Page with retrieved jobs

### <a name="operation4"></a> Method: 'POST', route '/v1/jobs/get_job_by_id'

Get job by id

**Request body:**
- job_id: string - 

**Response body:**
- job: JobV1 - finded job 

### <a name="operation5"></a> Method: 'POST', route '/v1/jobs/start_job_by_id'

Start job by id

**Request body:**
 - job_id: string - job id for start
 - timeout: number - timeout for execution in ms

**Response body:**
- job: JobV1 - started job 

### <a name="operation5"></a> Method: 'POST', route '/v1/jobs/start_job_by_type'

 Start fist free job by type

**Request body:**
 - type: string - job type
 - timeout: number - timeout for execution in ms

**Response body:**
- job: JobV1 - started job 

### <a name="operation5"></a> Method: 'POST', route '/v1/jobs/extend_job'

Extend job execution limit on timeout value

**Request body:**
 - job_id: string - job id for extend
 - timeout: number - timeout for execution in ms

**Response body:**
- job: JobV1 - extended job 

### <a name="operation5"></a> Method: 'POST', route '/v1/jobs/abort_job'

Abort job

**Request body:**
- job_id: string - job id for abort

**Response body:**
- job: JobV1 - aborted job 

### <a name="operation5"></a> Method: 'POST', route '/v1/jobs/complete_job'

Complete job

**Request body:**
- job_id: string - job id for complete

**Response body:**
 - job: JobV1 - completed job 

### <a name="operation5"></a> Method: 'POST', route '/v1/jobs/delete_job_by_id'

Delete job by id

**Request body:**
- job_id: string - job id for delete

**Response body:**
- job: JobV1 - deleted job 

### <a name="operation5"></a> Method: 'POST', route '/v1/jobs/delete_jobs'

Delete all jobs

**Request body:**

**Response body:**
Return occured error or null for success