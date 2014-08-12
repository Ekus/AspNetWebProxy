<%@ WebHandler Language="C#" Class="EkusDashboardSite.ImageProxy" %>
using System;
using System.Collections;
using System.Data;
using System.Drawing;
using System.IO;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Net;

namespace EkusDashboardSite
{

    /// <summary>
    /// Based on ClientAccess class from http://www.eggheadcafe.com/tutorials/aspnet/c0046ba1-5df5-486a-8145-6b76a40ea43d/silverlight-handling-cro.aspx 
    /// </summary>
     public class ImageProxy: IHttpHandler
    {
         public void ProcessRequest(HttpContext context)
         {
             string imageUrl = context.Request["url"].ToString();
			 
			//HttpWebRequest client = (HttpWebRequest)WebRequest.Create(imageUrl);
			//client.Credentials = new NetworkCredential(
			//    "PLLEBIZ",
			//    "nps2014!@#", 
			//    "DE-S-0129030");
			//client.PreAuthenticate = true;
			 string proxy = "127.0.0.1:8888";
			 
			 HttpWebRequest req = (HttpWebRequest)WebRequest.Create(imageUrl);
			 if (proxy != null) req.Proxy = new WebProxy(proxy, true);
			 // if SOAPAction header is required, add it here...
			 req.Headers.Add("SOAPAction", "\"\"");
			 req.ContentType = "text/xml;charset=\"utf-8\"";
			 req.Accept = "text/xml";
			// req.Method = "POST";
			 req.Credentials = new NetworkCredential(
				"PLLEBIZ",
				"nps2014!@#",
				"DE-S-0129030");
			 req.PreAuthenticate = true;
			req.KeepAlive = false;
			 req.Timeout = -1;

			 Stream stm;
			 WebResponse resp = req.GetResponse();
			 stm = resp.GetResponseStream();
			 StreamReader r = new StreamReader(stm);
			 // process SOAP return doc here. For now, we'll just send the XML out to the browser ...
//			 context.Response.ContentType = resp.ContentType;
			 context.Response.Write(r.ReadToEnd());
         }

         public bool IsReusable
        {
             get
             {
                  return false;
            }
        }
    }
}