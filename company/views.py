# Create your views here.
from django.core.urlresolvers import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import CreateView, UpdateView, DeleteView
from django_filters.views import FilterView
from braces.views import LoginRequiredMixin
from company.models import Company
from .filters import CompanyFilter
from .forms import CompanyForm


class CompanyListView(LoginRequiredMixin, FilterView):
    model = Company
    filterset_class = CompanyFilter
    paginate_by = 25
    queryset = Company.objects.with_query_count().all()


class CompanyCreate(LoginRequiredMixin, CreateView):
    model = Company
    form_class = CompanyForm


class CompanyUpdate(LoginRequiredMixin, UpdateView):
    model = Company
    form_class = CompanyForm


class CompanyDelete(LoginRequiredMixin, DeleteView):
    model = Company
    success_url = reverse_lazy('company:list')

class FieldToDisplay:
    def __init__(self, name):
        self.name = name


class CompanyDetailView(LoginRequiredMixin, DetailView):
    model = Company
    queryset = Company.objects.with_query_count().all()


    FIELDS_TO_DISPLAY = (
        'common_name',
        'plRegistered'
    )
    fields = [FieldToDisplay('kuku2'), FieldToDisplay('kuku3')]

    def __init__(self):
        for field in CompanyDetailView.FIELDS_TO_DISPLAY:
            self.fields.append(FieldToDisplay('kuku'))
