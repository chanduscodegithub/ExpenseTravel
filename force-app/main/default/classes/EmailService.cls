public class EmailService {
    public static void sendWelcomeEmail(String recipientEmail) {
        // Set the HTML content for the email
        String htmlBody = getEmailHtmlBody();

        // Create the email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {recipientEmail});
        email.setSubject('Welcome to Our Company!');
        email.setHtmlBody(htmlBody);

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    public static String getEmailHtmlBody() {
        // HTML content for the email
        String htmlContent = 
        '<!doctype html>' +
        '<html lang="en">' +
        '<head>' +
            '<meta charset="UTF-8" />' +
            '<meta name="viewport" content="width=device-width, initial-scale=1.0" />' +
            '<title>Welcome Card</title>' +
            '<style>' +
                'body { margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4; height: 100vh; }' +
                '.a4-wrapper { width: 125mm; background-color: #ffffff; position: relative; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); height: 80%; display: grid; grid-template-rows: 1fr 1fr 1fr; }' +
                '.footer { display: flex; flex-direction: column; justify-content: end; }' +
                '.header { position: relative; height: 140px; background: linear-gradient(to right, #003d6f, #0060a0); color: white; }' +
                '.header .waves { position: absolute; bottom: 0; width: 100%; height: 50px; background: url("data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 1200 120\' preserveAspectRatio=\'none\'><path d=\'M0,49C120,94,360,94,600,49s480-49,600,0V120H0Z\' fill=\'%23ffffff\' opacity=\'0.2\'/><path d=\'M0,72C120,120,360,120,600,72s480-72,600,0V120H0Z\' fill=\'%23ffffff\' opacity=\'0.4\'/><path d=\'M0,96C120,146,360,146,600,96s480-96,600,0V120H0Z\' fill=\'%23ffffff\'/></svg>"); background-repeat: no-repeat; background-size: cover; }' +
                '.header h1 { margin: 0; padding: 30px; text-align: left; font-size: 32px; font-weight: bold; }' +
                '.photo-wrapper { position: absolute; top: 3%; left: 80%; transform: translateX(-50%); width: 140px; height: 140px; border-radius: 50%; border: 5px solid white; overflow: hidden; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); background-color: #fff; }' +
                '.photo-wrapper img { width: 100%; height: 100%; object-fit: cover; }' +
                '.content { margin: 1rem 30px 0px; }' +
                '.content h2 { font-size: 24px; color: #003d6f; margin: 0px; }' +
                '.content p { font-size: 14px; line-height: 1.6; color: #333; margin: 1rem 0rem; }' +
                '.cta { font-size: 16px; font-weight: bold; color: #003d6f; margin: 0px; }' +
                '.footer img { width: 100px; margin: 0px 30px 10px; }' +
                '.container { width: 100%; height: 95%; display: flex; justify-content: center; align-items: center; padding-top: 2rem; }' +
            '</style>' +
        '</head>' +
        '<body>' +
            '<div class="container">' +
                '<div class="a4-wrapper">' +
                    '<div class="header">' +
                        '<h1>Let\'s Welcome</h1>' +
                        '<div class="waves"></div>' +
                    '</div>' +
                    '<div class="photo-wrapper">' +
                        '<img src="https://avatars.mds.yandex.net/get-shedevrum/12154225/img_3c2e97e8f57711ee97860a0d9f74bed2/orig" alt="Hemanjali Sood" />' +
                    '</div>' +
                    '<div class="content">' +
                        '<h2>Hemanjali Sood</h2>' +
                        '<p>Hemanjali has joined us as a <strong>"CX Cloud Senior Developer"</strong> for India region.</p>' +
                        '<p>Hemanjali is a seasoned professional with 5 years of experience, including 2+ years as a Java Backend Developer at TCS, contributing to a key Indian Government project. Over the past 3 years, she has excelled as a Mulesoft Developer, delivering 9 successful projects. She was previously associated with Apisero Inc. before joining CRMIT.</p>' +
                        '<p>Outside of work, Hemanjali enjoys listening to music and reading books.</p>' +
                        '<p class="cta">Please join us in extending a warm welcome to Hemanjali.</p>' +
                    '</div>' +
                    '<div class="footer">' +
                        '<img src="https://www.crmit.com/wp-content/uploads/2022/07/CRMIT-Main-partner-1.png" alt="CRMIT Logo" />' +
                        '<svg id="wave" style="transform: rotate(0deg); transition: 0.3s" viewBox="0 0 1440 150" version="1.1" xmlns="http://www.w3.org/2000/svg">' +
                            '<defs>' +
                                '<linearGradient id="sw-gradient-0" x1="0" x2="0" y1="1" y2="0">' +
                                    '<stop stop-color="rgba(62, 84.178, 243, 1)" offset="0%"></stop>' +
                                    '<stop stop-color="rgba(11, 65.697, 255, 1)" offset="100%"></stop>' +
                                '</linearGradient>' +
                            '</defs>' +
                            '<path style="transform: translate(0, 0px); opacity: 1" fill="#00497f" d="M0,0L20,2.5C40,5,80,10,120,20C160,30,200,45,240,42.5C280,40,320,20,360,20C400,20,440,40,480,42.5C520,45,560,30,600,35C640,40,680,65,720,80C760,95,800,100,840,102.5C880,105,920,105,960,102.5C1000,100,1040,95,1080,97.5C1120,100,1160,110,1200,100C1240,90,1280,60,1320,45C1360,30,1400,30,1440,25C1480,20,1520,10,1560,10C1600,10,1640,20,1680,30C1720,40,1760,50,1800,45C1840,40,1880,20,1920,27.5C1960,35,2000,70,2040,70C2080,70,2120,35,2160,30C2200,25,2240,50,2280,70C2320,90,2360,105,2400,95C2440,85,2480,50,2520,42.5C2560,35,2600,55,2640,55C2680,55,2720,35,2760,30C2800,25,2840,35,2860,40L2880,45L2880,150L2860,150C2840,150,2800,150,2760,150C2720,150,2680,150,2640,150C2600,150,2560,150,2520,150C2480,150,2440,150,2400,150C2360,150,2320,150,2280,150C2240,150,2200,150,2160,150C2120,150,2080,150,2040,150C2000,150,1960,150,1920,150C1880,150,1840,150,1800,150C1760,150,1720,150,1680,150C1640,150,1600,150,1560,150C1520,150,1480,150,1440,150C1400,150,1360,150,1320,150C1280,150,1240,150,1200,150C1160,150,1120,150,1080,150C1040,150,1000,150,960,150C920,150,880,150,840,150C800,150,760,150,720,150C680,150,640,150,600,150C560,150,520,150,480,150C440,150,400,150,360,150C320,150,280,150,240,150C200,150,160,150,120,150C80,150,40,150,20,150L0,150Z"></path>' +
                        '</svg>' +
                    '</div>' +
                '</div>' +
            '</div>' +
        '</body>' +
        '</html>';
        return htmlContent;
    }
}