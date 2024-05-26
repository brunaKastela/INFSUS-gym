import { render, screen } from '@testing-library/react'
import NotFoundPage from '../components/NotFound';

test("Example 1 renders successfully", () => {
    render(<NotFoundPage/>);

    const element = screen.getByText(/Stranica koju tražite ne postoji./i);
    expect(element).toBeInTheDocument();

    const secondEl = screen.getByText(/početnu stranicu/i);
    expect(secondEl).toBeInTheDocument();
})