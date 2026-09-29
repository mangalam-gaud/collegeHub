package com.college.servlet;

import com.college.dao.*;
import com.college.model.*;
import com.college.util.DBUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/library/*")
public class LibraryServlet extends HttpServlet {
    private final LibraryDAO libraryDAO = new LibraryDAO();
    private final UserDAO userDAO = new UserDAO();

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/library/" + page + ".jsp").forward(req, resp);
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "books":
                String q = req.getParameter("q");
                String cat = req.getParameter("category");
                String status = req.getParameter("status");
                int page = parseInt(req.getParameter("page"), 1);
                int size = 20;
                req.setAttribute("books", libraryDAO.searchBooks(q, parseInt(cat, 0), status, (page-1)*size, size));
                req.setAttribute("totalBooks", libraryDAO.countBooks(q, parseInt(cat, 0), status));
                req.setAttribute("q", q == null ? "" : q);
                req.setAttribute("category", cat == null ? "" : cat);
                req.setAttribute("status", status == null ? "" : status);
                req.setAttribute("page", page);
                view(req, resp, "books");
                break;
            case "book-form":
                String editId = req.getParameter("edit");
                if (editId != null) req.setAttribute("editBook", libraryDAO.getBookById(Integer.parseInt(editId)));
                view(req, resp, "book-form");
                break;
            case "issues":
                String issueStatus = req.getParameter("status");
                req.setAttribute("issues", libraryDAO.getAllIssues(issueStatus, 0, 50));
                req.setAttribute("status", issueStatus == null ? "" : issueStatus);
                view(req, resp, "issues");
                break;
            case "my-issues":
                LibraryMember member = libraryDAO.getMemberByUserId(user.getId());
                if (member != null) {
                    req.setAttribute("issues", libraryDAO.getIssuesByMember(member.getId()));
                }
                view(req, resp, "my-issues");
                break;
            case "issue-book":
                String bookId = req.getParameter("bookId");
                if (bookId != null) {
                    req.setAttribute("book", libraryDAO.getBookById(Integer.parseInt(bookId)));
                    req.setAttribute("members", userDAO.getByRole("STUDENT"));
                }
                view(req, resp, "issue-book");
                break;
            default:
                req.setAttribute("totalBooks", libraryDAO.countBooks(null, 0, null));
                req.setAttribute("availableBooks", libraryDAO.countBooks(null, 0, "AVAILABLE"));
                req.setAttribute("issuedBooks", libraryDAO.countBooks(null, 0, "ISSUED"));
                req.setAttribute("recentIssues", libraryDAO.getAllIssues(null, 0, 5));
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "book-save": {
                LibraryBook book = new LibraryBook();
                String idStr = req.getParameter("id");
                book.setIsbn(req.getParameter("isbn"));
                book.setTitle(req.getParameter("title"));
                book.setAuthor(req.getParameter("author"));
                book.setPublisher(req.getParameter("publisher"));
                book.setEdition(req.getParameter("edition"));
                book.setPublicationYear(parseInt(req.getParameter("publicationYear"), 0));
                book.setCategoryId(parseInt(req.getParameter("categoryId"), 0));
                book.setTotalCopies(parseInt(req.getParameter("totalCopies"), 1));
                book.setAvailableCopies(parseInt(req.getParameter("availableCopies"), 1));
                book.setLocationRack(req.getParameter("locationRack"));
                book.setLocationShelf(req.getParameter("locationShelf"));
                book.setPrice(parseDouble(req.getParameter("price"), 0));
                book.setLanguage(req.getParameter("language"));
                book.setPages(parseInt(req.getParameter("pages"), 0));
                book.setDescription(req.getParameter("description"));
                book.setCoverImage(req.getParameter("coverImage"));
                book.setStatus(req.getParameter("status"));
                if (idStr != null && !idStr.isBlank()) book.setId(Integer.parseInt(idStr));
                libraryDAO.createBook(book);
                resp.sendRedirect(req.getContextPath() + "/library/books");
                break;
            }
            case "issue-book": {
                LibraryIssue issue = new LibraryIssue();
                issue.setBookId(Integer.parseInt(req.getParameter("bookId")));
                issue.setMemberId(Integer.parseInt(req.getParameter("memberId")));
                issue.setIssueDate(req.getParameter("issueDate"));
                issue.setDueDate(req.getParameter("dueDate"));
                issue.setIssuedBy(user.getId());
                libraryDAO.issueBook(issue);
                resp.sendRedirect(req.getContextPath() + "/library/issues?saved=1");
                break;
            }
            case "return-book": {
                String issueId = req.getParameter("issueId");
                if (issueId != null) {
                    libraryDAO.returnBook(Integer.parseInt(issueId), user.getId());
                    resp.sendRedirect(req.getContextPath() + "/library/issues?returned=1");
                }
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/library/dashboard");
        }
    }

    private int parseInt(String s, int def) { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
    private double parseDouble(String s, double def) { try { return Double.parseDouble(s); } catch (Exception e) { return def; } }
}