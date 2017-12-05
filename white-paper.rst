:orphan:
:priority: 0.99

-----------------------
Tarantool - White Paper
-----------------------

.. raw:: html

  <section id="page-white-paper-banner" style="background-image: url('_static/images/tarantool-io/banners/white-paper.jpg')">
    <div clas="row" class="form-row">
      <div class="col-xs-12 col-sm-12 col-md-7 text-center">
        <div class="form-row-text-left-wrap">
          <h2>Free Download: Optimizing Your Application and Microservice Performance</h2>
        </div>
      </div>
      <div class="hidden-xs hidden-sm col-md-5" id="paper-form">
        <form>
          <div class="row">
            <div class="col-xs-12" style="position: relative">
              <div class="demo-header-tag">Download the White Paper</div>
              <span class="triangle whitepaper"></span>
            </div>
          </div>
          <div class="row">
            <div class="col-xs-12">
              <label>First Name*:</label>
              <input type="text" class="form-control required" name="first_name" placeholder=""> </div>
          </div>
          <div class="row">
            <div class="col-xs-12">
              <label>Last Name*:</label>
              <input type="text" class="form-control required" name="last_name" placeholder=""> </div>
          </div>
          <div class="row">
            <div class="col-xs-12">
              <label>Email*:</label>
              <input type="text" class="form-control required" name="email" placeholder=""> </div>
          </div>
          <div class="row">
            <div class="col-xs-12">
              <label>Phone Number:</label>
              <input type="text" class="form-control required" name="phone" placeholder=""> </div>
          </div>
          <div class="row">
            <div class="col-xs-12">
              <label>Company Name*:</label>
              <input type="text" class="form-control required" name="company_name" placeholder=""> </div>
          </div>
          <div class="row">
            <div class="col-xs-12 col-sm-6 col-sm-offset-3 form-btn-row">
              <button type="button" class="form-submit-btn btn-white-page"> Download Now </button>
            </div>
          </div>
          <div class="row confidential">
            <p class="text-center">We respect your privacy and will never sell your email address or spam you.</p>
          </div>
          <input class="hidden" type="radio" name="white-paper" value="true" checked="">
        </form>
      </div>
    </div>
  </section>
  <section id="page-white-paper-content">
    <div class="container">
      <div class="row">
        <div class="col-xs-12 col-sm-12 hidden-md hidden-lg">
          <form>
            <div class="row">
              <div class="col-xs-12" style="position: relative">
                <div class="demo-header-tag">Download the White Paper</div>
                <span class="triangle whitepaper"></span>
              </div>
            </div>
            <div class="row">
              <div class="col-xs-12">
                <label>First Name*:</label>
                <input type="text" class="form-control required" name="first_name" placeholder=""> </div>
            </div>
            <div class="row">
              <div class="col-xs-12">
                <label>Last Name*:</label>
                <input type="text" class="form-control required" name="last_name" placeholder=""> </div>
            </div>
            <div class="row">
              <div class="col-xs-12">
                <label>Email*:</label>
                <input type="text" class="form-control required" name="email" placeholder=""> </div>
            </div>
            <div class="row">
              <div class="col-xs-12">
                <label>Phone Number:</label>
                <input type="text" class="form-control required" name="phone" placeholder=""> </div>
            </div>
            <div class="row">
              <div class="col-xs-12">
                <label>Company Name*:</label>
                <input type="text" class="form-control required" name="company_name" placeholder=""> </div>
            </div>
            <div class="row">
              <div class="col-xs-12 col-sm-6 col-sm-offset-3 form-btn-row">
                <button type="button" class="form-submit-btn btn-white-page"> Download Now </button>
              </div>
            </div>
            <div class="row confidential">
              <p class="text-center">We respect your privacy and will never sell your email address or spam you.</p>
            </div>
            <input class="hidden" type="radio" name="white-paper" value="true" checked="">
          </form>
        </div>
      </div>
      <div class="row">
        <div class="col-xs-12 col-sm-12 col-md-7" id="description">
          <br>
          <p class="text-center">
            <img src="_static/images/tarantool-io/whitepaper/cover1.png">
          </p>
          <br>
          <p>
            <b>Discover how Oracle, MySQL, PostgreSQL, and other relational databases can amplify your data growth with Replicas
              and a Smart Cache:</b>
          </p>
          <br>
          <p>Database management systems (DBMS) can drive key application and microservice performance pitfalls. Smart caches
            can solve many of these issues. By combining a smart cache, with an application server and full disk memory database
            for one modern system, you are able to fully optimize your existing systems. Discover how this is done.</p>
          <br>
          <p>This white paper includes:</p>
          <ul>
            <li>Actual tests and results with Postgres and MySQL</li>
            <li>Why your data growth may be stunted and how to resolve it</li>
            <li>How smart caches can solve many issues and solve microservice performance pitfalls</li>
          </ul>
          <br>
          <p>Download this latest white paper to discover how to rescue your data growth now!</p>
        </div>
        <div class="hidden-xs hiden-sm col-md-5"> </div>
      </div>
    </div>
  </section>
  <form action="/src/php/show_whitepaper.php" method="POST" id="show_whitepaper" class="invisible">
    <input type="hidden" name="whitepaperurl" value="/web/assets/pdfs/Optimizing Application and Microservice Performance.pdf">
  </form>
  <script language="javascript">
    function form_submission_success() {
      $("#show_whitepaper").submit();
    }
  </script>