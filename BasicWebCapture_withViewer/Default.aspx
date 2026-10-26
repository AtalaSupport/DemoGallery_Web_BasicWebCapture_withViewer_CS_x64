<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="BasicWebCapture_withViewer.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <!-- Script includes for Web Viewing -->
    <script src="WebDocViewer/jquery-3.5.1.min.js" type="text/javascript"></script>
    <script src="WebDocViewer/jquery-ui-1.14.0.min.js" type="text/javascript"></script>
    <script src="WebDocViewer/raphael-min.js" type="text/javascript"></script>
    <script src="WebDocViewer/clipboard.min.js" type="text/javascript"></script>
    <script src="WebDocViewer/atalaWebDocumentViewer.js" type="text/javascript"></script>
    <!-- Style for Web Viewer -->
    <link href="WebDocViewer/jquery-ui-1.14.0.min.css" rel="Stylesheet" type="text/css" />
    <link href="WebDocViewer/atalaWebDocumentViewer.css" rel="Stylesheet" type="text/css" />
    <!-- Script includes for Web Capture -->
    <script src="/WebCapture/atalaWebCapture.js" type="text/javascript"></script>


    <script type="text/javascript">
    var _viewer = null;
    var _thumbs = null;

    // Initialize Web Scanning and Web Viewing... this will run at startup
    $(function () {
        _viewer = new Atalasoft.Controls.WebDocumentViewer({
            parent: $('#_containerViewer'), // parent container to put the viewer in
            toolbarparent: $('#_toolbar1'), // parent container to put the viewer toolbar in
            serverurl: '/WebDocViewerHandler.ashx', // server handler url to send image requests to
            allowannotations: true, // flag to enable annotations
            savepath: 'Saved/', // relative url to save annotation data to
            showscrollbars: true,
            forcepagefit: true
        });
        _thumbs = new Atalasoft.Controls.WebDocumentThumbnailer({
            parent: $('#_containerThumbs'),
            serverurl: '/WebDocViewerHandler.ashx',
            allowannotations: true,
            viewer: _viewer,
            allowdragdrop: true,
            showscrollbars: true
        });
        try {
            Atalasoft.Controls.Capture.WebScanning.initialize({
                handlerUrl: 'WebCaptureHandler.ashx',
                onUploadCompleted: function (eventName, eventObj) {
                    if (eventObj.success) {
                        _thumbs.OpenUrl("atala-capture-upload/" + eventObj.documentFilename);
                        Atalasoft.Controls.Capture.CaptureService.documentFilename = eventObj.documentFilename;
                    }
                },
                onScanError: scanErrorHandler,
                scanningOptions: { applyVRS: false, showScannerUI: true }
            });
        } catch (error) {
            alert('Thrown error: ' + error.description);
            Atalasoft.Controls.Capture.WebScanning.dispose();
        }
    });

    // this is needed because if you do not use this code, then only the system default scanner will ever be used
    function scanWithSelectedScanner() {
        Atalasoft.Controls.Capture.WebScanning.scanningOptions.scanner = $('.atala-scanner-list').val();
        Atalasoft.Controls.Capture.WebScanning.scan();
    }


    //// this is a realy simplified error handler for now... we can expand on this later
    //function scanErrorHandler(msg, params) {
    //    alert(msg);
    //}

    /// This is an updated handler with more sophisticated handling of certain errors
    function scanErrorHandler(msg, params) {
        switch (msg) {
            case Atalasoft.Controls.Capture.Errors.noTwain:
                alert("This web capture application requires that you have at least one valid TWAIN device installed and configured. Please ensure you install the TWAIN driver for your scanner device(s) then re-visit this site.");
                break;
            case Atalasoft.Controls.Capture.Errors.oldWindowsService:
                alert("The version of Kofax WebCapture Service running on the multiuser system you're using is out of date. Please contact your system administrator.");
                break;
            case Atalasoft.Controls.Capture.Errors.webServiceMissed:
                alert("The Kofax WebCapture Service on the multiuser system you're using is not running. Please contact your system administrator.");
                break;
            case Atalasoft.Controls.Capture.Errors.noPlugin:
                var installerUrl = window.location.protocol + "//" + window.location.host + "/WebCapture/" + params.filename;
                window.open(installerUrl, '_downloadService');
                alert(
                    "The WingScan Web Scanning service is not available. \n\n" +
                    "If the download doesn't start automatically, please download from " + installerUrl + "\n\n" +
                    "If you are not prompted to install, the service may be installed but not running. \n\n" +
                    "enable it by running from START->All Programs->Kofax Web Capture Service->Kofax Web Capture Service  \n\n" +
                    "Refresh your browser when completed.");
                break;
            case Atalasoft.Controls.Capture.Errors.oldPlugin:
                var installerUrl = window.location.protocol + "//" + window.location.host + "/WebCapture/" + params.filename;
                window.open(installerUrl, '_downloadService');
                alert(
                    "The WingScan Web Scanning service is out of date.<br />" +
                    "If the download does not begin automatically, please go to " +
                    params.filename);
                break;
            default:
                alert(msg);
                break;
        }
    }
</script>

</head>
<body>
    <form id="form1" runat="server">
    <div id="scanDiv">
        <h1>Basic WingScan Web Capture Demo</h1>
        <h3>Using WingScan and WITH Viewer</h3>
        <p>Select your scanner and click the scan button... the file will be uploaded to /atala-capture-upload/ with a unique filename (the filename will appear in the status below)</p>
        <p>&nbsp;</p>
        <p>Select Scanner:
            <select class="atala-scanner-list" disabled="disabled" name="scannerList" style="width:22em">
                <option selected="selected">(no scanners available)</option>
            </select>
            &nbsp;
            <!-- DO NOT USE <input type="button" class="atala-scan-button" value="Scan" /> -->
            <input type="button" id="scanNOW" value="Scan" onclick="scanWithSelectedScanner(); return false;" />
        </p>

    </div>
    <div style="width: 900px;">
    <div id="_toolbar1"></div>
    <div id="_containerThumbs" style="width: 180px; height: 600px;
    display: inline-block;"></div>
    <div id="_containerViewer" style="width: 710px; height: 600px;
    display: inline-block;"></div>
    </div>
    </form>
</body>
</html>
