<%@ WebHandler Language="C#" Class="MiniProxy" %>
using System;
using System.Collections;
using System.Data;
using System.Drawing;
using System.IO;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Net;
using System.Collections.Generic;
using NLog;

	/// <summary>
	/// Receives a web request with target URL, invokes another web request to the target URL with added NTLM credentials, and returns the response to the original caller.
	/// </summary>
public class MiniProxy : IHttpHandler
	{
		Logger log = LogManager.GetCurrentClassLogger();

		//		public MiniProxy()
		//		{
		//			Console.Beep(20000, 3000);
		//		}
		
		public void ProcessRequest(HttpContext context)
		{
			string webServiceUrl = context.Request["url"].ToString();

			//Dictionary<string, string> map = new Dictionary<string, string>();
			//map["url"] = "http://///";
			//map.Add("url", "htttp://////");

			//webServiceUrl = map[context.Request["url"].ToString()];

//			string proxy = "127.0.0.1:8888";
			string proxy = null;

			HttpWebRequest req = (HttpWebRequest)WebRequest.Create(webServiceUrl);
			if (proxy != null) req.Proxy = new WebProxy(proxy, true);
			// if SOAPAction header is required, add it here...
			req.Headers.Add("SOAPAction", context.Request.Headers["SOAPAction"]);
			req.ContentType = "text/xml;charset=\"utf-8\"";
			req.Accept = "text/xml";
			req.Method = context.Request.HttpMethod; // "POST";
			req.Credentials = new NetworkCredential(
				"PLLEBIZ",
				"nps2014!@#",
				"DE-S-0129030");
			req.PreAuthenticate = true;
			req.KeepAlive = false;
			req.Timeout = -1;


			if (req.Method == "POST")
			{
				// copy original request "body" to the new request
				string input = new StreamReader(context.Request.InputStream).ReadToEnd();

				// encode it using the predefined encoding (see above, req.ContentType)
				System.Text.UTF8Encoding encoding = new System.Text.UTF8Encoding();
				byte[] bytesToSend = encoding.GetBytes(input);

				// Set the content length of the string being posted.
				req.ContentLength = bytesToSend.Length;

				Stream newStream = req.GetRequestStream(); // This method has the side effect of initiating delivery of the request in its current state to the server. Any properties like the request method, content type or content length as well as any custom headers need to be assigned before calling the GetRequestStream() method.
				newStream.Write(bytesToSend, 0, bytesToSend.Length);

				// Close the Stream object.
				newStream.Close();
			} // else GET, no body to send. Other verbs are not supported at the moment.

			HttpWebResponse resp = null;
			string output = null;
			string status = null;
			try 
			{
				resp= (HttpWebResponse)req.GetResponse();
			}
			catch (WebException ex) 
			{
				log.Debug("Status: {0}", ex.Status);
				log.Debug("Exception: {0}", ex);
				if (ex.Response != null) 
				{ 
					resp = (HttpWebResponse)ex.Response;
				} else { output = ex.ToString(); }    
			}

			if (null!=resp) 
			{
				Stream respStream = resp.GetResponseStream();
				StreamReader r = new StreamReader(respStream);
				// process SOAP return doc here. For now, we'll just send the XML out to the browser ...
				output = r.ReadToEnd();
				status = string.Format("{0} {1}", (int)((HttpWebResponse)resp).StatusCode, ((HttpWebResponse)resp).StatusDescription);
				log.Debug("Remote server returned status: {0}", status);
				
				log.Debug("Remote server returned headers:");
				foreach(string h in resp.Headers.Keys){ log.Debug("{0}: {1}", h, resp.Headers[h]); }

				log.Debug("Proxy scrypt is returning headers:");
				foreach (string h in context.Response.Headers.Keys) { log.Debug("{0}: {1}", h, resp.Headers[h]); }
				
				//context.Response.Headers.Add(resp.Headers);
			}



			log.Debug("Proxy response status: {0}", context.Response.Status);
			log.Debug("Proxy response status code: {0}", context.Response.StatusCode);
			
			log.Debug(output);
			context.Response.Status = status;
			log.Debug("Proxy response status: {0}", context.Response.Status);
			log.Debug("Proxy response status code: {0}", context.Response.StatusCode);
			context.Response.Write(output);
		}

		public bool IsReusable
		{
			get
			{
				return false;
			}
		}
	}