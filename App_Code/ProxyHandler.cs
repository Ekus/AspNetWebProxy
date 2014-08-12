using System.Web;
namespace AspNetWebProxy
{
    public class FooHandler : IHttpHandler
    {
        public bool IsReusable
        {
            get { return true; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.Write("<h1>Foo</h1>");
        }
    }
}