package com.college.servlet;

import com.college.dao.*;
import com.college.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/fee/*")
public class FeeServlet extends HttpServlet {
    private final FeeDAO feeDAO = new FeeDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AcademicDAO academicDAO = new AcademicDAO();
    private final ProgramDAO programDAO = new ProgramDAO();

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/fee/" + page + ".jsp").forward(req, resp);
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "structures":
                req.setAttribute("structures", feeDAO.getAllFeeStructures());
                view(req, resp, "structures");
                break;
            case "structure-form":
                String editId = req.getParameter("edit");
                if (editId != null) req.setAttribute("editStructure", feeDAO.getFeeStructureById(Integer.parseInt(editId)));
                req.setAttribute("programs", programDAO.getAllPrograms());
                req.setAttribute("academicYears", academicDAO.getAllAcademicYears());
                view(req, resp, "structure-form");
                break;
            case "payments":
                String studentId = req.getParameter("studentId");
                if (studentId != null) {
                    req.setAttribute("payments", feeDAO.getFeePaymentsByStudent(Integer.parseInt(studentId)));
                    req.setAttribute("student", userDAO.getById(Integer.parseInt(studentId)));
                } else {
                    req.setAttribute("payments", feeDAO.getAllFeePayments());
                }
                view(req, resp, "payments");
                break;
            case "payment-form":
                String payStudentId = req.getParameter("studentId");
                if (payStudentId != null) {
                    req.setAttribute("student", userDAO.getById(Integer.parseInt(payStudentId)));
                    req.setAttribute("structure", feeDAO.getApplicableFeeStructure(Integer.parseInt(payStudentId)));
                }
                view(req, resp, "payment-form");
                break;
            case "scholarships":
                req.setAttribute("scholarships", feeDAO.getAllScholarships());
                view(req, resp, "scholarships");
                break;
            case "scholarship-form":
                String schEdit = req.getParameter("edit");
                if (schEdit != null) req.setAttribute("editScholarship", feeDAO.getScholarshipById(Integer.parseInt(schEdit)));
                req.setAttribute("academicYears", academicDAO.getAllAcademicYears());
                view(req, resp, "scholarship-form");
                break;
            case "my-fees":
                FeeStructure fs = feeDAO.getApplicableFeeStructure(user.getId());
                List<FeePayment> payments = feeDAO.getFeePaymentsByStudent(user.getId());
                req.setAttribute("feeStructure", fs);
                req.setAttribute("payments", payments);
                if (fs != null) {
                    double totalPaid = payments.stream().filter(p -> "COMPLETED".equals(p.getStatus()))
                            .mapToDouble(FeePayment::getAmountPaid).sum();
                    req.setAttribute("totalPaid", totalPaid);
                    req.setAttribute("balance", fs.getTotalFee() - totalPaid);
                }
                view(req, resp, "my-fees");
                break;
            default:
                req.setAttribute("structureCount", feeDAO.getAllFeeStructures().size());
                req.setAttribute("paymentCount", feeDAO.getAllFeePayments().size());
                req.setAttribute("scholarshipCount", feeDAO.getAllScholarships().size());
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "structure-save": {
                FeeStructure fs = new FeeStructure();
                String idStr = req.getParameter("id");
                fs.setName(req.getParameter("name"));
                fs.setProgramId(Integer.parseInt(req.getParameter("programId")));
                fs.setSemester(Integer.parseInt(req.getParameter("semester")));
                fs.setCategory(req.getParameter("category"));
                fs.setAcademicYearId(Integer.parseInt(req.getParameter("academicYearId")));
                fs.setTuitionFee(Double.parseDouble(req.getParameter("tuitionFee")));
                fs.setLabFee(Double.parseDouble(req.getParameter("labFee")));
                fs.setLibraryFee(Double.parseDouble(req.getParameter("libraryFee")));
                fs.setSportsFee(Double.parseDouble(req.getParameter("sportsFee")));
                fs.setExamFee(Double.parseDouble(req.getParameter("examFee")));
                fs.setDevelopmentFee(Double.parseDouble(req.getParameter("developmentFee")));
                fs.setHostelFee(Double.parseDouble(req.getParameter("hostelFee")));
                fs.setTransportFee(Double.parseDouble(req.getParameter("transportFee")));
                fs.setMiscFee(Double.parseDouble(req.getParameter("miscFee")));
                fs.setDueDate(req.getParameter("dueDate"));
                fs.setLateFeePerDay(Double.parseDouble(req.getParameter("lateFeePerDay")));
                fs.setMaxLateFee(Double.parseDouble(req.getParameter("maxLateFee")));
                fs.setActive("on".equals(req.getParameter("isActive")));
                if (idStr != null && !idStr.isBlank()) fs.setId(Integer.parseInt(idStr));
                feeDAO.createFeeStructure(fs);
                resp.sendRedirect(req.getContextPath() + "/fee/structures");
                break;
            }
            case "payment-save": {
                FeePayment fp = new FeePayment();
                fp.setStudentId(Integer.parseInt(req.getParameter("studentId")));
                fp.setFeeStructureId(Integer.parseInt(req.getParameter("feeStructureId")));
                fp.setPaymentDate(java.time.LocalDateTime.now().toString());
                fp.setAmountPaid(Double.parseDouble(req.getParameter("amountPaid")));
                fp.setPaymentMode(req.getParameter("paymentMode"));
                fp.setTransactionRef(req.getParameter("transactionRef"));
                fp.setReceiptNumber("RCPT-" + System.currentTimeMillis());
                fp.setReceivedBy(user.getId());
                fp.setStatus(req.getParameter("status"));
                fp.setLateFee(Double.parseDouble(req.getParameter("lateFee")));
                fp.setDiscount(Double.parseDouble(req.getParameter("discount")));
                fp.setRemarks(req.getParameter("remarks"));
                feeDAO.recordFeePayment(fp);
                resp.sendRedirect(req.getContextPath() + "/fee/payments?studentId=" + fp.getStudentId() + "&saved=1");
                break;
            }
            case "scholarship-save": {
                Scholarship s = new Scholarship();
                String idStr = req.getParameter("id");
                s.setName(req.getParameter("name"));
                s.setCode(req.getParameter("code"));
                s.setDescription(req.getParameter("description"));
                s.setEligibilityCriteria(req.getParameter("eligibilityCriteria"));
                s.setAmountType(req.getParameter("amountType"));
                s.setAmountValue(Double.parseDouble(req.getParameter("amountValue")));
                s.setMaxRecipients(Integer.parseInt(req.getParameter("maxRecipients")));
                s.setAcademicYearId(Integer.parseInt(req.getParameter("academicYearId")));
                s.setApplicationStart(req.getParameter("applicationStart"));
                s.setApplicationEnd(req.getParameter("applicationEnd"));
                s.setActive("on".equals(req.getParameter("isActive")));
                if (idStr != null && !idStr.isBlank()) s.setId(Integer.parseInt(idStr));
                feeDAO.createScholarship(s);
                resp.sendRedirect(req.getContextPath() + "/fee/scholarships");
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/fee/dashboard");
        }
    }
}