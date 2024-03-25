package com.appmod.ta.modresorts;

import java.io.IOException;
import java.util.Hashtable;

import javax.naming.InitialContext;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AuthServlet extends HttpServlet {

	private static final long serialVersionUID = -4751096228274971485L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
        //Get an initial context
        try {
            Hashtable ht = new Hashtable();
            ht.put("java.naming.factory.initial", "com.ibm.websphere.naming.WsnInitialContextFactory");
            ht.put("java.naming.provider.url", "corbaloc:iiop:localhost:2809");
            InitialContext ctx = new InitialContext(ht);
        } catch(Exception e) { 
            System.out.println("Unable to create the initial context");
        }

        //Invalidate the session  and logout
        HttpSession session = request.getSession();
        session.invalidate();


	}
	
	@Override
	public void init() throws ServletException {
		System.out.println("Servlet " + this.getServletName() + " has started");
	}

	@Override
	public void destroy() {
		System.out.println("Servlet " + this.getServletName() + " has stopped");
	}
	
}


