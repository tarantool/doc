:orphan:
:priority: 0.99

-------------------
Tarantool - Contact
-------------------

.. raw:: html

  <section id="page-contact">
    <div class="container">
      <div class="row">
        <div class="col-xs-12 col-md-6 col-md-offset-1">
          <form class="hidden-sm hidden-md hidden-lg">
            <div class="row">
              <div class="col-xs-12" style="position: relative">
                <div class="demo-header-tag">Contact Us</div>
                <span class="triangle enterprise"></span>
              </div>
            </div>
            <div class="row">
              <div class="col-xs-12 col-sm-6">
                <input type="text" class="form-control required" name="first_name" placeholder="First Name"> </div>
              <div class="col-xs-12 col-sm-6">
                <input type="text" class="form-control required" name="last_name" placeholder="Last Name"> </div>
            </div>
            <div class="row">
              <div class="col-xs-12">
                <input type="text" class="form-control required" name="email" placeholder="Email"> </div>
            </div>
            <div class="row">
              <div class="col-xs-12">
                <input type="text" class="form-control required" name="phone" placeholder="Phone Number"> </div>
            </div>
            <div class="row">
              <div class="col-xs-12">
                <input type="text" class="form-control required" name="company_name" placeholder="Company Name"> </div>
            </div>
            <div class="row">
              <div class="col-xs-12">
                <textarea rows="5" type="text" class="form-control" name="message" placeholder="Feel free to add a message"></textarea>
              </div>
            </div>
            <div class="row">
              <div class="col-xs-12 col-sm-6 col-sm-offset-3 form-btn-row">
                <button type="button" class="form-submit-btn red-product-btn"> Send </button>
              </div>
            </div>
            <div class="row confidential">
              <p class="text-center">All information in confidential. We will not spam you.</p>
            </div>
            <input class="hidden" type="radio" name="Contact Form" value="true" checked="">
            <input class="hidden" type="hidden" name="white_paper_url" value="">
          </form>
        </div>
      </div>
  </section>
  <section id="page-contact">
    <div class="row map-it-section">
      <div class="col-xs-10 col-xs-offset-1 col-sm-8 col-sm-offset-2">
        <div class="row map-it-row text-center">
          <div class="col-xs-12 col-sm-4">
            <div class="map-it-box">
              <h3>Moscow</h3>
              <p>125167 Leningradsky Prospekt 39
                <br/> Bld. 79, Moscow, RU
              </p>
              <p class="map-trigger" data-key="Moscow">Asia Office Map it!</p>
            </div>
          </div>
          <div class="col-xs-12 col-sm-4">
            <div class="map-it-box">
              <h3>Silicon Valley</h3>
              <p>201 San Antonio Circle
                <br/> Mountain View, CA 94040
              </p>
              <p class="map-trigger" data-key="siliconValley">North America Office Map it!</p>
            </div>
          </div>
          <div class="col-xs-12 col-sm-4">
            <div class="map-it-box">
              <h3>Amsterdam</h3>
              <p>Barbara Strozzilaan 201. 1083HN.
                <br/> Amsterdam, The Netherlands
              </p>
              <p class="map-trigger" data-key="Amsterdam">EMEA Office Map it!</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="btn-group" role="group">
        <button type="button" class="btn map-trigger contact-btn btn-active" data-key="siliconValley">Silicon Valley</button>
        <button type="button" class="btn map-trigger contact-btn" data-key="Moscow">Moscow</button>
        <button type="button" class="btn map-trigger contact-btn" data-key="Amsterdam">Amsterdam</button>
      </div>
    </div>
    <div id="map"></div>
  </section>